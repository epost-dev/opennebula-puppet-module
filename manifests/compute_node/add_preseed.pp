#
# Define one::compute_node::add_preseed
#
# configure Debian preseed file
#
define one::compute_node::add_preseed($preseed_tmpl = 'one/preseed.cfg.erb', $data = undef) {

  validate_string ($preseed_tmpl)
  file { "/var/lib/one/etc/preseed.d/${name}.cfg":
    ensure  => present,
    owner   => oneadmin,
    group   => oneadmin,
    content => template($preseed_tmpl),
  }
}
