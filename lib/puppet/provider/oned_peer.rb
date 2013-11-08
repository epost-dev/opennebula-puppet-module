require 'puppet/parser/functions'
Puppet::Type.type(:oned_peer).provide(:oned) do
    def self.instances
	begin
          nodes = []
          Puppet.debug "oned_peer: Executing `onehost list`"
          cmdout = %x{sudo -u oneadmin onehost list}
	  cmdstatus = $?
	  if (cmdstatus != 0) then
	         raise(Puppet::Error, "oned_peer: Could not execute `onehost list` correctly!")
	  end
	  cmdout.split(/\n/).each do |line|
              if /^\s+\d+\s+(\S+)\s+/.match(line) then
                  nodes.push($1)
              end
          end
          nodes

	rescue => err
	  raise(Puppet::Error, "oned_peer: #{err.message}: #{err.backtrace}")
	end
    end
    def exists?
	nodes.include?($resource[:node].to_s)
    end
    def create
	begin
          if !self.exists? then
              Puppet.debug "oned_peer: Executing `onehost create #{resource[:node]} -i kvm -v kvm -n 802.1Q`" 
              %x{sudo -u oneadmin onehost create #{resource[:node]} -i kvm -v kvm -n 802.1Q}
	      cmdstatus = $?
	      if (cmdstatus != 0) then
	             raise(Puppet::Error, "oned_peer: Could not execute `onehost create` correctly!")
	      end
          end
	rescue => err
	  raise(Puppet::Error, "oned_peer: #{err.message}: #{err.backtrace}")
	end
    end
    def destroy
	begin
          if self.exists? then
              Puppet.debug "oned_peer: Executing `onehost delete #{resource[:node]}`"
              %x{sudo -u oneadmin onehost delete resource[:node]}
	      cmdstatus = $?
	      if (cmdstatus != 0) then
	             raise(Puppet::Error, "oned_peer: Could not execute `onehost delete` correctly!")
	      end
          end
	rescue => err
	  raise(Puppet::Error, "oned_peer: #{err.message}: #{err.backtrace}")
	end
    end
end
