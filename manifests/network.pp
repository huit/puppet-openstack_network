define openstack_network::network (
  $params,
  $host_number,
  $host_location,
  $host_domain,
) {
  validate_re($host_number,
              '^\d+$',
              "'${host_number}' does not look numeric.")

  validate_re($host_location,
              '^[^_\s]+$',
              "'${host_location}' may not contain whitespace or underscores.")

  validate_re($host_domain,
              '^[[:alnum:]]+(\.[[:alnum:]]+){0,}$',
              "'${host_domain}' does not look like a domain name.")

  validate_hash($params)
  $bond = $params['bond']
  $mtu = $params['mtu']
  $ipaddress = $params['ipaddress']
  $netmask = $params['netmask']
  $gateway = $params['gateway']
  $vlan = $params['vlan']

  validate_hash($bond)

  # configure physical interfaces
  $bond_numbers = keys($bond)
  $bond_number = $bond_numbers[0]
  $bond_device = $vlan ? {
    false   => "bond${bond_number}",
    default => "bond${bond_number}.${vlan}",
  }
  $bond_interfaces = $bond[$bond_number]
  $bond_params = {
    'master' => $bond_device,
  }
  each($bond_interfaces) |$interface| { ensure_resource('openstack_network::bond_slave', $interface, $bond_params) }

  # configure bonding group
  $bridge_device = "br-${title}"
  $bridge_params = {
    'ensure'       => 'up',
    'bridge'       => $bridge_device,
    'mtu'          => $mtu,
    'bonding_opts' => 'mode=4 miimon=100',
  }
  if ( ! defined(Network::Bond::Bridge[$bond_device]) ) {
    ensure_resource('network::bond::bridge',
                    $bond_device,
                    $bridge_params)
  }

  # configure bridge
  network::bridge::static { $bridge_device:
    ensure    => 'up',
    ipaddress => $ipaddress,
    netmask   => $netmask,
    gateway   => $gateway,
  }

  # configure routing rules


  # configure host entries
  $short_hostname = "os${title}${host_number}-${host_location}"
  $long_hostname = "${short_hostname}.${host_domain}"
  host { $long_hostname:
    ensure       => 'present',
    provider     => 'augeas',
    host_aliases => [ $short_hostname ],
    ip           => $ipaddress,
  }
}
