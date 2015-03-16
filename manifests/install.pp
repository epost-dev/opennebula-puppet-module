# Class one::install
#
# packages needed by both (compute node and head)
#
class one::install {

  file { '/root/.gemrc':
    ensure  => 'file',
    content => "---\nhttp_proxy: ${one::params::http_proxy}\n"
  }

  File['/root/.gemrc'] -> Package <| provider == "gem" |>

  package { $one::params::dbus_pkg:
    ensure  => present,
    require => Class['one::prerequisites'],
  }

  file { '/var/lib/one':
    ensure  => 'directory',
    owner   => 'oneadmin',
    group   => 'oneadmin',
  }
}
