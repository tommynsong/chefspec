require 'chef_zero/server'
require 'chef/cookbook_loader'
require 'chef/cookbook_uploader'

require_relative 'file_cache_path_proxy'
require_relative 'server_methods'
require_relative 'solo_runner'

module ChefSpec
  class ServerRunner < SoloRunner
    include ChefSpec::ServerMethods

    # @see (SoloRunner#initialize)
    def initialize(options = {})
      # Unlike the SoloRunner, the file_cache_path needs to remain consistent
      # for every Chef run or else the Chef client tries to loads the same
      # cookbook multiple times and will encounter deprecated logic when
      # creating LWRPs. It also slows down the entire process.
      options[:file_cache_path] ||= RSpec.configuration.file_cache_path ||
        ChefSpec::FileCachePathProxy.instance.file_cache_path

      # Call super, but do not pass in the block because we want to customize
      # our yielding.
      super(options, &nil)

      Chef::Config[:client_key]      = client_key
      Chef::Config[:client_name]     = 'chefspec'
      Chef::Config[:node_name]       = 'chefspec'
      Chef::Config[:solo]            = false

      Chef::Config[:chef_server_url]  = server.url
      Chef::Config[:http_retry_count] = 0

      # Start the Chef Zero instance in the background
      server.start_background
      at_exit { server.stop if server.running? }

      # Unlike the SoloRunner, the node AND server object are yielded for
      # customization
      yield node, self if block_given?
    end

    #
    # Upload the cookbooks to the Chef Server.
    #
    def upload_cookbooks!
      loader = Chef::CookbookLoader.new(Chef::Config[:cookbook_path])
      loader.load_cookbooks
      cookbook_uploader_for(loader).upload_cookbooks
    end

    #
    # The uploader for the cookbooks.
    #
    # @param [Chef::CookbookLoader] loader
    #   the Chef cookbook loader
    #
    # @return [Chef::CookbookUploader]
    #
    def cookbook_uploader_for(loader)
      Chef::CookbookUploader.new(loader.cookbooks)
    end

    # @see (SoloRunner#converge)
    def converge(*recipe_names)
      upload_cookbooks!

      super do
        yield if block_given?

        # Save the node back to the server for searching purposes
        client.register
        node.save
      end
    end

    private

    #
    # The path to the insecure Chef Zero private key on disk. Because Chef
    # requires the path to a file instead of the contents of the key (why),
    # this method dynamically writes the +ChefZero::PRIVATE_KEY+ to disk and
    # then returns that path.
    #
    # @return [String]
    #   the path to the client key on disk
    #
    def client_key
      tmp = Dir.mktmpdir
      path = File.join(tmp, 'client.pem')
      File.open(path, 'wb') { |f| f.write(ChefZero::PRIVATE_KEY) }
      at_exit { FileUtils.rm_rf(tmp) }
      path
    end

    #
    # A randomly assigned, open port for run the Chef Zero server.
    #
    # @return [Fixnum]
    #
    def port
      return @port if @port

      @server = TCPServer.new('127.0.0.1', 0)
      @port   = @server.addr[1].to_i
      @server.close

      return @port
    end
  end
end
