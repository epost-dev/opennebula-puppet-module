# Class one::service
#
# generic service needed by both (cmopute node and head)
#
class one::service {
  service { $one::params::dbus_srv:
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package[$one::params::dbus_pkg],
  }
}
