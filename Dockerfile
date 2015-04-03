FROM rwaffen/puppet
MAINTAINER Robert Waffen "rwaffen@gmail.com"

ADD . /etc/puppet/modules/one
#CMD puppet apply --modulepath=/etc/puppet/modules -e "class { one: oned => true, node => false, sunstone => true, }"
