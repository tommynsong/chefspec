yum_package 'explicit_action' do
  action :lock
end

yum_package 'with_attributes' do
  version '1.0.0'
  action  :lock
end

yum_package 'specifying the identity attribute' do
  package_name 'identity_attribute'
  action       :lock
end
