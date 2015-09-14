FROM centos:6
MAINTAINER Robert Waffen "robert.waffen@epost-dev.de"

ENV HOSTNAME localhost
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV FACTER_operatingsystemmajrelease="6"
ENV FACTER_operatingsystemrelease="6.7"
ENV FACTER_lsbmajdistrelease="6"

RUN yum -y install https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm epel-release
RUN yum makecache && yum -y install puppet tar hostname

RUN puppet module install puppetlabs-inifile
RUN puppet module install puppetlabs-stdlib
RUN puppet module install puppetlabs-concat
RUN puppet module install puppetlabs-mysql
RUN puppet module install puppetlabs-apache
RUN puppet module install puppetlabs-corosync
RUN puppet module install rodjek-logrotate

COPY hiera/hiera.yaml /etc/puppet/
COPY hiera/docker.yaml /etc/puppet/data/