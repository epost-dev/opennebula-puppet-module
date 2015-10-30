# How to Contribute

## Information first

Before starting on a feature or a bug, please tell the community about it. Simply create an issue on the github Issue Tracker.
Describe the issue in a few words, for example what the error is or what feature you have in mind.
So everybody knows about the problem/feature and that someone is working on it.

## Creating a pull request

* Create a github account if you don't have one already.
* Fork our master branch into your github account.
* Make a feature branch for your change.
* Do your thing.
* Don't forget the tests!
* Open a pull request on the github site.
* If the automatic test are fine, we will merge
* If they are failing, please fix them!

If you plan to do a complex change, it may be good to create a pull request before you are done. So the others can see what
you are planning and maybe correct the trajectory if needed.

## Coding conventions

TDB

## Testing

If you add new features, add new tests for them. If you change something, adapt the tests to the fix, if needed.

### rspec-puppet

To run the rspec-puppet tests for this module install the needed gems with [bundler](http://bundler.io):

     bundle install --path=vendor

And run the tests and puppet-lint:

     bundle exec rake

### Acceptance Tests

Please note: Acceptance tests require vagrant & virtualbox to be installed.

To run acceptance tests on the default centos 6 vm:

     bundle exec rake beaker

### Vagrant

To deploy a Opennebula instance locally run:

     vagrant up <boxname>

where "boxname" is currently centos.

### Docker

To deploy a OpenNebula instance locally in a docker container run these commands:

First build an image with puppet and the sources in it (Depending on centos:6):

    cd docker
    docker build --rm -t epost-dev/one .
    cd ..

Run puppet in the container, choose one:

Only build a container which acts as a OpenNebula head, gui, but not the kvm things:

    docker run --rm -v $(pwd):/etc/puppet/modules/one epost-dev/one puppet apply /etc/puppet/modules/one/spec/docker-int/one-head.pp

Only build a container which acts like an OpenNebula node:

    # here is a common error i wasn't able to fix. centos 6 in docker has some issues with ksm
    docker run --rm -v $(pwd):/etc/puppet/modules/one epost-dev/one puppet apply /etc/puppet/modules/one/spec/docker-int/one-node.pp

Build a container which acts as head and node

    docker run --rm -v $(pwd):/etc/puppet/modules/one epost-dev/one puppet apply /etc/puppet/modules/one/spec/docker-int/one-head-node.pp

Build a container which has an apache for the OpenNebula Sunstone configured:

    docker run --rm -v $(pwd):/etc/puppet/modules/one epost-dev/one puppet apply /etc/puppet/modules/one/spec/docker-int/one-head-httpd.pp

This Docker command will add the current directory as ```ect/puppet/modules/one```. So one can test each new change without committing or rebuilding the image.

The "spec" files can be found in the spec/docker-int directory of this project. One will build a one head,
one will build a node and one a head which also can be a node. 