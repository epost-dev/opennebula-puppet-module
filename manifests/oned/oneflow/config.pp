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
  $oneflow_one_xmlrpc       = $one::oneflow_one_xmlrpc,
  $oneflow_lcm_interval     = $one::oneflow_lcm_interval,
  $oneflow_host             = $one::oneflow_host,
  $oneflow_port             = $one::oneflow_port,
  $oneflow_default_cooldown = $one::oneflow_default_cooldown,
  $oneflow_shutdown_action  = $one::oneflow_shutdown_action,
  $oneflow_action_number    = $one::oneflow_action_number,
  $oneflow_action_period    = $one::oneflow_action_period,
  $oneflow_vm_name_template = $one::oneflow_vm_name_template,
  $oneflow_core_auth        = $one::oneflow_core_auth,
  $oneflow_debug_level      = $one::oneflow_debug_level,
){
  file { '/etc/one/oneflow-server.conf':
    ensure  => file,
    mode    => '0640',
    content => template('one/oneflow-server.conf.erb'),
  }
}
