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

end
