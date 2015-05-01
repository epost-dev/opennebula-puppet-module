# Class one::service
#
# generic service needed by both (cmopute node and head)
#
class one::service(
  $dbus_srv = $one::dbus_srv,
) {
  service { $dbus_srv:
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
  }
}
