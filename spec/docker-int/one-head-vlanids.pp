class { 'one':
  oned => true,
  node => false,
  sunstone => true,
  one_version => $one_version,
  vlan_ids_start => 10,
  vlan_ids_reserved => '400, 410',
  vxlan_ids_start => '12',
  package_ensure_latest => false,
}
