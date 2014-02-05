define one::compute_node::add_kickstart() {

  file { "/var/lib/one/etc/kickstart.d/${name}.ks":
    ensure  => present,
    owner   => oneadmin,
    group   => oneadmin,
    content => template('one/kickstart.erb'),
  }
}
