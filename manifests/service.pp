# Class one::service
#
# generic service needed by both (cmopute node and head)
#
class one::service {
  service { $one::dbus_srv:
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package[$one::dbus_pkg],
  }
}
