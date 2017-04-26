#
# == Class one::compute_node
#
# Installs OpenNebula required packages and configuration files for OpenNebula
# virtualization hosts
#
# === Author
# ePost Development GmbH
# (c) 2013
#
# Contributors:
# - Martin Alfke
# - Achim Ledermueller (Netways)
# - Sebastian Saemann (Netways)
#
# === Parameters
# none
#
# === Usage
#
# do not use this class directly. Use class one instead.
# See documentation in one/manifests/init.pp
#
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one::compute_node(
  $puppetdb = $one::puppetdb,
  $oneid    = $one::oneid,
  $im_mad   = $one::im_mad,
  $vm_mad   = $one::vm_mad,
  $vn_mad   = $one::vn_mad,
) {
  include one::prerequisites
  include one::install
  include one::config
  include one::service
  include one::compute_node::config
  include one::compute_node::service
  include one::compute_node::install

  Class['one::prerequisites'] ->
  Class['one::install'] ->
  Class['one::config'] ->
  Class['one::compute_node::install'] ->
  Class['one::compute_node::config'] ~>
  Class['one::compute_node::service'] ~>
  Class['one::service']

  if ($puppetdb == true) {
    # Register the node as a onehost in the puppetdb
    if $one::version_gte_5_0 {
      @@onehost { $::fqdn :
        tag    => $oneid,
        im_mad => $im_mad,
        vm_mad => $vm_mad,
      }
    }
    else {
      @@onehost { $::fqdn :
        tag    => $oneid,
        im_mad => $im_mad,
        vm_mad => $vm_mad,
        vn_mad => $vn_mad,
      }
    }
  }
}
