FROM rwaffen/puppetbase
MAINTAINER Robert Waffen "rwaffen@gmail.com"

ENV HOSTNAME "one.local"
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV FACTER_operatingsystemmajrelease="7"
env FACTER_lsbmajdistrelease="7"

RUN yum -y install hostname
#RUN puppet module install epostdev-one
RUN puppet module install puppetlabs-apt
ADD . /etc/puppet/modules/one
RUN puppet apply --modulepath=/etc/puppet/modules -e "class { one: oned => true, sunstone => true, }"

EXPOSE 80
