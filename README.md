opennebula-puppet-module
========================

The one (short for OpenNebula) module allows to install and manage your OpenNebula cloud.

[![Build Status](https://travis-ci.org/epost-dev/opennebula-puppet-module.png)](https://travis-ci.org/epost-dev/opennebula-puppet-module)

Requirements
------------

### Wheezy
Tested with puppet 3.4.3 from wheezy backports.
To use the open nebula repositories for wheezy, set one::enable_opennebula_repo to true and install packages for puppet and the puppetlabs-apt module:

    apt-get install -t wheezy-backports puppet
    apt-get install -t wheezy-backports puppet-module-puppetlabs-apt


Running tests
-------------
To run the rspec-puppet tests for this module install the needed gems with [bundler](http://bundler.io):

     bundle install --path=vendor

And run the tests and puppet-lint:

     bundle exec rake

Support
-------

For questions or bugs [create an issue on Github](https://github.com/epost-dev/opennebula-puppet-module/issues/new).

License
-------

Copyright © 2013 [Deutsche Post E-Post Development GmbH](http://epost.de)

Distributed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
