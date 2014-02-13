require 'spec_helper'

describe 'openstack_network', :type => :class do
  describe 'on RedHat platform' do
    let(:facts) { { :osfamily => 'RedHat' } }

    describe 'with default params' do

      it { should compile.with_all_deps }

      it {
        should create_class('openstack_network')
        should create_class('network_global')
      }

    end

  end

  describe 'on Debian platform' do
    let(:facts) { { :osfamily => 'Debian' } }

    it {
      expect { should raise_error(Puppet::Error, /only runs on RedHat/) }
    }

  end
end
