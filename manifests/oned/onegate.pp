# == Class one::oned::onegate
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
class one::oned::onegate  {
  include one::prerequisites
  include one::params
  include one::oned::onegate::install
  include one::oned::onegate::config
  include one::oned::onegate::service
  Class['one::prerequisites'] -> Class['one::params'] ->
  Class['one::oned::onegate::install'] ->
  Class['one::oned::onegate::config'] ~> Class['one::oned::onegate::service']
}
