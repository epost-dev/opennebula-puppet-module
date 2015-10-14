#
# Define one::compute_node::add_preseed
#
# configure Debian preseed file
#
define one::compute_node::add_preseed(
  $preseed_tmpl      = 'one/preseed.cfg.erb',
  $debian_mirror_url = $one::compute_node::config::debian_mirror_url,
  $data              = undef
) {
  validate_string ($preseed_tmpl)
  file { "/var/lib/one/etc/preseed.d/${name}.cfg":
    ensure  => file,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    content => template($preseed_tmpl),
  }
}
