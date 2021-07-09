require 'chefspec'

describe 'apt_package::purge' do
  platform 'ubuntu'

  describe 'purges an apt_package with an explicit action' do
    it { is_expected.to purge_apt_package('explicit_action') }
    it { is_expected.to_not purge_apt_package('not_explicit_action') }
  end

  describe 'purges an apt_package with attributes' do
    it { is_expected.to purge_apt_package('with_attributes').with(version: '1.0.0') }
    it { is_expected.to_not purge_apt_package('with_attributes').with(version: '1.2.3') }
  end

  describe 'purges an apt_package when specifying the identity attribute' do
    it { is_expected.to purge_apt_package('identity_attribute') }
  end
end
