#
# == Define one::oned::peer
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
define one::oned::peer (
    $vtype = $one::vtype,
    $ntype = $one::ntype,
){
  oned_peer { $name:
    vtype => $vtype,
    ntype => $ntype,
  }
}

