# == Class one::compute_node::service
#
# Installation and Configuration of OpenNebula
# http://opennebula.org/
#
# === Author
# ePost Development GmbH
# (c) 2013
#
# Contributors:
# - Martin Alfke
# - Achim Ledermueller (Netways GmbH)
# - Sebastian Saemann (Netways GmbH)
#
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one::compute_node::service {
  service { 'libvirtd':
    ensure    => 'running',
    hasstatus => true,
    enable    => true,
  }
  service { 'ksmtuned':
    ensure    => 'stopped',
    enable    => false,
    hasstatus => true,
  }
  service { 'ksm':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }
}
