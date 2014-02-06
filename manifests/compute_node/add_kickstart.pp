define one::compute_node::add_kickstart($kickstart_tmpl = 'one/kickstart.ks.erb', $data = undef) {

  validate_string ($kickstart_tmpl)
  file { "/var/lib/one/etc/kickstart.d/${name}.ks":
    ensure  => present,
    owner   => oneadmin,
    group   => oneadmin,
    content => template($kickstart_tmpl),
  }
}
