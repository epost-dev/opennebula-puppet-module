module Puppet::Util::Opennebula::CLI
  def login
    credentials = File.read('/var/lib/one/.one/one_auth').strip.split(':')
    user = credentials[0]
    password = credentials[1]
    " --user #{user} --password #{password}"
  end

  def invoke(property)
    `onetemplate #{property} --xml #{self.class.login}`
  end
end
