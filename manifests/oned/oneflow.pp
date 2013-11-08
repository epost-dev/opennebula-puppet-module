# == Class one::oned::oneflow
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
class one::oned::oneflow  {
  include one::prerequisites
  include one::params
  include one::oned::oneflow::install
  include one::oned::oneflow::config
  include one::oned::oneflow::service
  Class['one::prerequisites'] -> Class['one::params'] ->
  Class['one::oned::oneflow::install'] ->
  Class['one::oned::oneflow::config'] ~> Class['one::oned::oneflow::service']
}
