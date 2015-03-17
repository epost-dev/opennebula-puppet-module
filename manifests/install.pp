# Class one::install
#
# packages needed by both (compute node and head)
#
class one::install (
  $http_proxy = $one::params::http_proxy,
  $dbus_pkg   = $one::params::dbus_pkg,
){

  file { '/root/.gemrc':
    ensure  => 'file',
    content => "---\nhttp_proxy: ${http_proxy}\n",
  }

  File['/root/.gemrc'] -> Package <| provider == "gem" |>

  package { $dbus_pkg:
    ensure  => present,
    require => Class['one::prerequisites'],
  }

  file { '/var/lib/one':
    ensure  => 'directory',
    owner   => 'oneadmin',
    group   => 'oneadmin',
  }
}
