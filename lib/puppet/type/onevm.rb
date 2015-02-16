# OpenNebula Puppet type for onevm
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
Puppet::Type.newtype(:onevm) do
  @doc = "Type for managing virtual machines in OpenNebula using the onevm" +
         "wrapper command."

  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of VM."
    validate do |value|
        fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newproperty(:template) do
    desc "Template to use for VM"
  end

  newproperty(:description) do
    desc "Description to use for VM"
    validate do |value|
        fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
  end

end
