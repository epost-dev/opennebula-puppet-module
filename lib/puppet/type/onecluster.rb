Puppet::Type.newtype(:onecluster) do
  @doc = "Type for managing clusters in OpenNebula using the onecluster" +
         "wrapper command."

  ensurable

  newparam(:name) do
    desc "Name of cluster."

    isnamevar

    validate do |value|
      if value !~ /^[a-zA-Z0-9 \-_]+$/ then
        self.fail "Not a cluster name."
      end
    end
  end

end
