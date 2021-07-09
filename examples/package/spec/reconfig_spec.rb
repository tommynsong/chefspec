require 'chefspec'

describe 'package::reconfig' do
  platform 'ubuntu'

  describe 'reconfigs a package with an explicit action' do
    it { is_expected.to reconfig_package('explicit_action') }
    it { is_expected.to_not reconfig_package('not_explicit_action') }
  end

  describe 'reconfigs a package with attributes' do
    it { is_expected.to reconfig_package('with_attributes').with(version: '1.0.0') }
    it { is_expected.to_not reconfig_package('with_attributes').with(version: '1.2.3') }
  end

  describe 'reconfigs a package when specifying the identity attribute' do
    it { is_expected.to reconfig_package('identity_attribute') }
  end

  describe 'reconfigs all packages when given an array of names' do
    it { is_expected.to reconfig_package(%w(with array)) }
  end
end
