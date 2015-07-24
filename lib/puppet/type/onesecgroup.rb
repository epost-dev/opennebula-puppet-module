# Opennebula onesecgroup type for Security Groups
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

Puppet::Type.newtype(:onesecgroup) do
  @doc = "Type for managing security groups in OpenNebula using the" +
         "onesecgroup wrapper command."

  ensurable

  # Capacity Section
  newparam(:name, :namevar => true) do
    desc "Name of security group."
    validate do |value|
      fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newproperty(:description) do
    desc "Description of the security group."
    validate do |value|
      fail("Invalid description: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newproperty(:rules, :array_matching => :all) do
    desc "An array of hashes, each defining a rule for the security group."
    defaultto []
    validate do |value|
      if value.is_a?( Hash)
        # TODO: validate each key
        valid_keys = [
          'protocol',
          'rule_type',
          'ip',
          'size',
          'range',
          'icmp_type',
        ]
        fail "#{(value.keys - valid_keys).join(' and ')} is not one of #{valid_keys.join(' or ')}" unless (value.keys - valid_keys).empty?
      end
    end
    munge do |value|
      if ! value.is_a?(Hash)
        fail 'each rule should be a hash'
      else
        value
      end
    end
  end

end
