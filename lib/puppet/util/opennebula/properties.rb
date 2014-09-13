module Puppet::Util::Opennebula::Properties
  def property_map(properties)
    properties.each do |property, mapping|

      define_method(property) do
        xml = REXML::Document.new(self.invoke("show", @resource.name, "--xml"))
        xml.get_elements(properties[property]).map(&:text)
      end
      define_method("#{property}=") do |arg|
        raise "Can not yet modify #{property} on a #{self.class.name}."
      end
    end
  end
end
