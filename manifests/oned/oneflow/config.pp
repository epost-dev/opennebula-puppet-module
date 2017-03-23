#
# == Class one::oned::oneflow::config
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
class one::oned::oneflow::config (
  $one_xmlrpc       = $one::oneflow_one_xmlrpc,
  $lcm_interval     = $one::oneflow_lcm_interval,
  $host             = $one::oneflow_host,
  $port             = $one::oneflow_port,
  $default_cooldown = $one::oneflow_default_cooldown,
  $shutdown_action  = $one::oneflow_shutdown_action,
  $action_number    = $one::oneflow_action_number,
  $action_period    = $one::oneflow_action_period,
  $vm_name_template = $one::oneflow_vm_name_template,
  $core_auth        = $one::oneflow_core_auth,
  $debug_level      = $one::oneflow_debug_level,
){
  file { '/etc/one/oneflow-server.conf':
    ensure  => file,
    content => template('one/oneflow-server.conf.erb'),
    notify  => Service['opennebula-flow'],
  }
}
