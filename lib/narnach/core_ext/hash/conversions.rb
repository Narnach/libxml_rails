require 'activesupport'

module Narnach #:nodoc:
  module CoreExtensions #:nodoc:
    module Hash #:nodoc:
      module Conversions
        # Contrary to XmlSimple, libxml_rails does not undasherize data in Hash#from_xml.
        # Disable dasherize by default to compensate for this.
        def to_xml(options = {})
          options[:dasherize]= false unless options.has_key?(:dasherize)
          super options
        end
      end
    end
  end
end

class Hash
  include Narnach::CoreExtensions::Hash::Conversions
end
