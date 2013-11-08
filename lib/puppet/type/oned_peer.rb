Puppet::Type.newtype(:oned_peer) do
    desc <<-EOT
        Peers a virtualization host (node) with oned.
    EOT

    #autorequire(:class) do
    #    ['dummyclass']
    #end

    ensurable do
        newvalue(:present) do
            provider.create
        end
        newvalue(:absent) do
            provider.destroy
        end
        defaultto :present
    end

    newparam(:node, :namevar => true) do
        desc "Peer host address (hostname or ip) to connect to."
    end
end

