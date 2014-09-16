Puppet::Type.newtype(:onehost) do
  @doc = <<-EOS
Type for managing hypervisor hosts in OpenNebula using the onehost wrapper
command.
EOS

  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of host."
    validate do |value|
        fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newproperty(:im_mad) do
    desc "Information Driver"
  end

  newproperty(:vm_mad) do
    desc "Virtualization Driver"
  end

  newproperty(:vn_mad) do
      desc "Network Driver"
  end

end
