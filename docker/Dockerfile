FROM epost-dev/puppet
MAINTAINER Robert Waffen "robert.waffen@epost-dev.de"

ADD . /etc/puppet/modules/one
ADD ./spec/docker-int/hiera/hiera.yaml /etc/puppet/
ADD ./spec/docker-int/hiera/docker.yaml /etc/puppet/data/