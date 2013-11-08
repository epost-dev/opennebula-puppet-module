# == Class one
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
# === Parameters
#
# $oneid <string> - default to one-cloud
#   set the id of the cloud
#
# $node true|false - default true
#  defines whether the host is node (virtualization host/worker)
#
# $oned true|false - default false
#   defines whether OpenNebula-Daemon should be installed.
#   OpenNebula-Daemon needs to run on the system where you want to manage your
#   OpenNebula systems.
#   You need exactly one OpenNebula Daemon in your infrastructure.
#
# $backend sqlite|mysql - default to sqlite
#   defines which backend should be used
#   supports sqlite or mysql
#   does not install mysql server, only uses information from params.pp
#
# $sunstone true|false - default false
#   defines where the Sunstone Webinterface should be installed.
#   Sunstone Webinterface is fully optional.
#
# $ldap true|false - default false
#   defines whether sunstone authentication to ldap should be enabled
#   ldap is fully optional
#
# $ha_setup true | false - default false
#   defines whether the oned should be run on boot
#
# $sunflow true|false - default false
#   defines whether the oneflow service should be installed
#
# === Usage
#
# install compute node
# class { one: }
#
# install opennebula management node (without sunstone webinterface)
# class { one: oned => true }
#
# install opennebula management node with sunstone webinterface
# class { one:
#   oned => true,
#   sunstone => true,
# }
#
# install opennebula sunstone webinterface only
# class { one: sunstone => true }
#
# installation of optional oneflow and onegate requires oned.
# class { one:
#   oned => true,
#   oneflow => true,
#   onegate => true,
# }
#
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one ( $oneid      = 'one-cloud',
            $node       = true,
            $oned       = false,
            $sunstone   = false,
            $ldap       = false,
            $oneflow    = false,
            $onegate    = false,
            $backend    = 'sqlite',
            $ha_setup   = false,
            ) {

  include one::params

  if ($oned) {
    include one::oned
  }
  if ($node) {
    include one::compute_node
  }

  if ($sunstone) {
    include one::oned::sunstone
  }
  if($oneflow) {
    class {'one::oned::oneflow': }
  }
  if($onegate) {
    class {'one::oned::onegate': }
  }
}
