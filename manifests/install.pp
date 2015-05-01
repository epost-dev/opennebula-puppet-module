# Class one::install
#
# packages needed by both (compute node and head)
#
class one::install (
  $http_proxy = $one::http_proxy,
  $dbus_pkg   = $one::dbus_pkg,
){
  File['/etc/gemrc'] -> Package <| provider == 'gem' |>

  file { '/etc/gemrc':
    ensure  => 'file',
    content => "---\nhttp_proxy: ${http_proxy}\n",
  } ->

  package { $dbus_pkg:
    ensure  => 'latest',
  }
}
