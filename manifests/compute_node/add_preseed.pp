define one::compute_node::add_preseed() {

  $vmtype = $name
  file { "/var/lib/one/etc/preseed.d/${name}.cfg":
    ensure  => present,
    owner   => oneadmin,
    group   => oneadmin,
    content => template('one/preseed.cfg.erb'),
  }
}
