# OpenNebula Puppet type for onecluster
#
# License: APLv2
#
# Authors:
# Based upon initial work from Ken Barber
# Modified by Martin Alfke
#
# Copyright
# initial provider had no copyright
# Deutsche Post E-POST Development GmbH - 2014, 2015
#

Puppet::Type.newtype(:onecluster) do
  @doc = "Type for managing clusters in OpenNebula using the onecluster" +
         "wrapper command."

  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of cluster."
    validate do |value|
      fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newproperty(:hosts, :array_matching => :all) do
    desc "Array with names of nodes to add to a cluster"
    defaultto []
    def insync?(is)
      is.sort == should.sort
    end
  end

  newproperty(:vnets, :array_matching => :all) do
    desc "Virtual Networks to add to the cluster - optional"
    defaultto []
    def insync?(is)
      is.sort == should.sort
    end
  end

  newproperty(:datastores, :array_matching => :all) do
    desc "Datastores to add to the cluster - optional"
    defaultto []
    def insync?(is)
      is.sort == should.sort
    end
  end

end
