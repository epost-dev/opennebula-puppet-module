#
# Define one::compute_node::add_kickstart
#
# defines the kickstart.ks file
#
define one::compute_node::add_kickstart(
  $kickstart_tmpl = 'one/kickstart.ks.erb',
  $networkconfig  = $one::compute_node::config::networkconfig,
  $partitions     = $one::compute_node::config::partitions,
  $data           = undef
) {
  validate_string ($kickstart_tmpl)
  file { "/var/lib/one/etc/kickstart.d/${name}.ks":
    ensure  => file,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    content => template($kickstart_tmpl),
  }
}
