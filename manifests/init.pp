# == Class: openstack_network
#
# Full description of class openstack_network here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { openstack_network:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Steve Huff <steve_huff@harvard.edu>
#
# === Copyright
#
# Copyright 2014 President and Fellows of Harvard College
#
class openstack_network (
  $host_number,
  $host_location,
  $host_domain,
  $admin_net   = $openstack_network::params::admin_net,
  $endpt_net   = $openstack_network::params::endpt_net,
  $mgmt_net    = $openstack_network::params::mgmt_net,
  $integ_net   = $openstack_network::params::integ_net,
  $float_net   = $openstack_network::params::float_net,
  $storage_net = $openstack_network::params::storage_net,
) inherits openstack_network::params {

  case $::osfamily {
    'RedHat': {}
    default: {
      fail("openstack_gluster_swift only runs on RedHat platforms, not '${::osfamily}'.")
    }
  }

  class { 'network::global':
    vlan => 'yes',
  }

  Openstack_network::Network {
    host_number   => $openstack_network::host_number,
    host_location => $openstack_network::host_location,
    host_domain   => $openstack_network::host_domain,
  }

  if $openstack_network::admin_net {
    validate_hash($openstack_network::admin_net)
    openstack_network::network { 'admin':
      params        => $openstack_network::admin_net,
    }
  }

  if $openstack_network::endpt_net {
    validate_hash($openstack_network::endpt_net)
    openstack_network::network { 'endpt':
      params => $openstack_network::endpt_net,
    }
  }

  if $openstack_network::mgmt_net {
    validate_hash($openstack_network::mgmt_net)
    openstack_network::network { 'mgmt':
      params => $openstack_network::mgmt_net,
    }
  }

  if $openstack_network::integ_net {
    validate_hash($openstack_network::integ_net)
    openstack_network::network { 'integ':
      params => $openstack_network::integ_net,
    }
  }

  if $openstack_network::float_net {
    validate_hash($openstack_network::float_net)
    openstack_network::network { 'float':
      params => $openstack_network::float_net,
    }
  }

  if $openstack_network::storage_net {
    validate_hash($openstack_network::storage_net)
    openstack_network::network { 'storage':
      params => $openstack_network::storage_net,
    }
  }

}
