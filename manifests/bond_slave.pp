define openstack_network::bond_slave (
  $master,
) {
  $macaddress_fact = "macaddress_${title}"
  $macaddress = inline_template('<%= scope.lookupvar(@macaddress_fact) -%>')
  validate_re($macaddress,
              '^[\dabcdefABCDEF]{2}(:[\dabcdefABCDEF]{2}){5}$',
              "'${macaddress}' does not look like a MAC address.")

  network::bond::slave { $title:
    macaddress   => $macaddress,
    ethtool_opts => "-K ${title} gro off",
    master       => $master,
  }
}
