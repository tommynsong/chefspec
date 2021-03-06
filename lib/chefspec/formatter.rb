require "chef/formatters/base"
require "chef/formatters/error_mapper"

module ChefSpec
  class ChefFormatter < Chef::Formatters::Base
    cli_name :chefspec

    # Called at the very start of a Chef Run
    def run_start(version); end

    def run_started(run_status); end

    # Called at the end a successful Chef run.
    def run_completed(node); end

    # Called at the end of a failed Chef run.
    def run_failed(exception); end

    # Called right after ohai runs.
    def ohai_completed(node); end

    # Already have a client key, assuming this node has registered.
    def skipping_registration(node_name, config); end

    # About to attempt to register as +node_name+
    def registration_start(node_name, config); end

    def registration_completed; end

    # Failed to register this client with the server.
    def registration_failed(node_name, exception, config)
      expecting_exception(exception) do
        description = Chef::Formatters::ErrorMapper.registration_failed(node_name, exception, config)
        display_error(description)
      end
    end

    # Called before Chef client loads the node data from the server
    def node_load_start(node_name, config); end

    # Failed to load node data from the server
    def node_load_failed(node_name, exception, config)
      expecting_exception(exception) do
        description = Chef::Formatters::ErrorMapper.node_load_failed(node_name, exception, config)
        display_error(description)
      end
    end

    # Error expanding the run list
    def run_list_expand_failed(node, exception)
      expecting_exception(exception) do
        description = Chef::Formatters::ErrorMapper.run_list_expand_failed(node, exception)
        display_error(description)
      end
    end

    # Called after Chef client has loaded the node data.
    # Default and override attrs from roles have been computed, but not yet applied.
    # Normal attrs from JSON have been added to the node.
    def node_load_completed(node, expanded_run_list, config); end

    # Called before the cookbook collection is fetched from the server.
    def cookbook_resolution_start(expanded_run_list); end

    # Called when there is an error getting the cookbook collection from the
    # server.
    def cookbook_resolution_failed(expanded_run_list, exception)
      expecting_exception(exception) do
        description = Chef::Formatters::ErrorMapper.cookbook_resolution_failed(expanded_run_list, exception)
        display_error(description)
      end
    end

    # Called when the cookbook collection is returned from the server.
    def cookbook_resolution_complete(cookbook_collection); end

    # Called before unneeded cookbooks are removed
    def cookbook_clean_start; end

    # Called after the file at +path+ is removed. It may be removed if the
    # cookbook containing it was removed from the run list, or if the file was
    # removed from the cookbook.
    def removed_cookbook_file(path); end

    # Called when cookbook cleaning is finished.
    def cookbook_clean_complete; end

    # Called before cookbook sync starts
    def cookbook_sync_start(cookbook_count); end

    # Called when cookbook +cookbook_name+ has been sync'd
    def synchronized_cookbook(cookbook_name); end

    # Called when an individual file in a cookbook has been updated
    def updated_cookbook_file(cookbook_name, path); end

    # Called when an error occurs during cookbook sync
    def cookbook_sync_failed(cookbooks, exception)
      expecting_exception(exception) do
        description = Chef::Formatters::ErrorMapper.cookbook_sync_failed(cookbooks, exception)
        display_error(description)
      end
    end

    # Called after all cookbooks have been sync'd.
    def cookbook_sync_complete; end

    # Called when library file loading starts
    def library_load_start(file_count); end

    # Called when library file has been loaded
    def library_file_loaded(path); end

    # Called when a library file has an error on load.
    def library_file_load_failed(path, exception)
      file_load_failed(path, exception)
    end

    # Called when library file loading has finished
    def library_load_complete; end

    # Called when LWRP loading starts
    def lwrp_load_start(lwrp_file_count); end

    # Called after a LWR or LWP has been loaded
    def lwrp_file_loaded(path); end

    # Called after a LWR or LWP file errors on load
    def lwrp_file_load_failed(path, exception)
      file_load_failed(path, exception)
    end

    # Called when LWRPs are finished loading
    def lwrp_load_complete; end

    # Called when an ohai plugin file loading starts
    def ohai_plugin_load_start(file_count); end

    # Called when an ohai plugin file has been loaded
    def ohai_plugin_file_loaded(path); end

    # Called when an ohai plugin file has an error on load.
    def ohai_plugin_file_load_failed(path, exception); end

    # Called when an ohai plugin file loading has finished
    def ohai_plugin_load_complete; end

    # Called before attribute files are loaded
    def attribute_load_start(attribute_file_count); end

    # Called after the attribute file is loaded
    def attribute_file_loaded(path); end

    # Called when an attribute file fails to load.
    def attribute_file_load_failed(path, exception)
      file_load_failed(path, exception)
    end

    # Called when attribute file loading is finished
    def attribute_load_complete; end

    # Called before resource definitions are loaded
    def definition_load_start(definition_file_count); end

    # Called when a resource definition has been loaded
    def definition_file_loaded(path); end

    # Called when a resource definition file fails to load
    def definition_file_load_failed(path, exception)
      file_load_failed(path, exception)
    end

    # Called when resource defintions are done loading
    def definition_load_complete; end

    # Called before recipes are loaded
    def recipe_load_start(recipe_count); end

    # Called after the recipe has been loaded
    def recipe_file_loaded(path); end

    # Called after a recipe file fails to load
    def recipe_file_load_failed(path, exception)
      file_load_failed(path, exception)
    end

    # Called when a recipe cannot be resolved
    def recipe_not_found(exception)
      expecting_exception(exception) do
        description = Chef::Formatters::ErrorMapper.file_load_failed(nil, exception)
        display_error(description)
      end
    end

    # Called when recipes have been loaded.
    def recipe_load_complete; end

    # Called before convergence starts
    def converge_start(run_context); end

    # Called when the converge phase is finished.
    def converge_complete; end

    # Called before action is executed on a resource.
    def resource_action_start(resource, action, notification_type = nil, notifier = nil); end

    # Called when a resource fails, but will retry.
    def resource_failed_retriable(resource, action, retry_count, exception); end

    # Called when a resource fails and will not be retried.
    def resource_failed(resource, action, exception)
      expecting_exception(exception) do
        description = Chef::Formatters::ErrorMapper.resource_failed(resource, action, exception)
        display_error(description)
      end
    end

    # Called when a resource action has been skipped b/c of a conditional
    def resource_skipped(resource, action, conditional); end

    # Called when a resource action has been completed
    def resource_completed(resource); end

    # Called after #load_current_resource has run.
    def resource_current_state_loaded(resource, action, current_resource); end

    # Called when resource current state load is skipped due to the provider
    # not supporting whyrun mode.
    def resource_current_state_load_bypassed(resource, action, current_resource); end

    # Called when evaluating a resource that does not support whyrun in whyrun mode
    def resource_bypassed(resource, action, current_resource); end

    # Called when a resource has no converge actions, e.g., it was already correct.
    def resource_up_to_date(resource, action); end

    # Called when a change has been made to a resource. May be called multiple
    # times per resource, e.g., a file may have its content updated, and then
    # its permissions updated.
    def resource_update_applied(resource, action, update); end

    # Called after a resource has been completely converged, but only if
    # modifications were made.
    def resource_updated(resource, action); end

    # Called before handlers run
    def handlers_start(handler_count); end

    # Called after an individual handler has run
    def handler_executed(handler); end

    # Called after all handlers have executed
    def handlers_completed; end

    # Called when an assertion declared by a provider fails
    def provider_requirement_failed(action, resource, exception, message); end

    # Called when a provider makes an assumption after a failed assertion
    # in whyrun mode, in order to allow execution to continue
    def whyrun_assumption(action, resource, message); end

    # An uncategorized message. This supports the case that a user needs to
    # pass output that doesn't fit into one of the callbacks above. Note that
    # there's no semantic information about the content or importance of the
    # message. That means that if you're using this too often, you should add a
    # callback for it.
    def msg(message); end

    private

    def file_load_failed(path, exception)
      expecting_exception(exception) do
        description = Chef::Formatters::ErrorMapper.file_load_failed(path, exception)
        display_error(description)
      end
    end

    def expecting_exception(exception, &block)
      yield unless ChefSpec::ExpectException.new(exception).expected?
    end
  end
end
