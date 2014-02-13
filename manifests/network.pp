define openstack_network::network (
  $params,
) {
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
  $bond_device = "bond${bond_number}"
  $bond_interfaces = $bond[0]
  $bond_params = {
    'master' => $bond_device,
  }
  ensure_resource('openstack_network::bond_slave',
                  $bond[0],
                  $bond_params)

  # configure bonding group
  $bridge_device = $vlan ? {
    false   => "br-${title}",
    default => "br-${title}.${vlan}",
  }
  network::bond::bridge { $bond_device:
    ensure       => 'up',
    bridge       => $bridge_device,
    mtu          => $mtu,
    bonding_opts => 'mode=4 miimon=100'
  }

  # configure bridge
  network::bridge::static { $bridge_device:
    ensure    => 'up',
    ipaddress => $ipaddress,
    netmask   => $netmask,
    gateway   => $gateway,
    mtu       => $mtu,
  }

  # configure routing rules


}
