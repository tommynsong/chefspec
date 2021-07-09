homebrew_package 'default_action'

homebrew_package 'explicit_action' do
  action :install
end

homebrew_package 'with_attributes' do
  version '1.0.0'
end

homebrew_package 'specifying the identity attribute' do
  package_name 'identity_attribute'
end
