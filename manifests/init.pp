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
# $vtype - default kvm
#  set virtualization type for opennebula compute node
#  supported vtypes:
#   - kvm
#   - xen3
#   - xen4
#   - vmware
#   - ec2
#   - dummy
#
# $ntype - default 802.1Q
#  set network type for opennebula compute node
#  supported tyes
#   - 802.1Q
#   - ebtables
#   - firewall
#   - ovswitch
#   - vmware
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
# $oneflow true|false - default false
#   defines whether the oneflow service should be installed
#
# $puppetdb true|false - default false
#   defines to use puppetDB to discover peer nodes
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
            $vtype      = 'kvm',
            $ntype      = '802.1Q',
            $oned       = false,
            $sunstone   = false,
            $ldap       = false,
            $oneflow    = false,
            $onegate    = false,
            $backend    = 'sqlite',
            $ha_setup   = false,
            $puppetdb   = false,
            ) {
  include one::params
  if ($oned) {
    if ( member(['kvm','xen3','xen4','vmware','ec2'], $vtype) ) {
      if ( member(['802.1Q','ebtables','firewall','ovswitch'], $ntype) ) {
        include one::oned
      } else {
        fail("Network Type: ${ntype} is not supported.")
      }
    } else {
      fail("Virtualization type: ${vtype} is not supported")
    }
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
  include one::install
  include one::config
  include one::service
}