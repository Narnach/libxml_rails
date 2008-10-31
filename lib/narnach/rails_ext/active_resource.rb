gem 'activeresource'
require 'active_resource'
require 'active_resource/formats/xml_format'

module Narnach
  module RailsExt
    module ActiveResource
      module Base
        # A method to convert the the resource to an XML string.
        #
        # This is a copy-adjusted version of ActiveResource's #to_xml, but
        # it uses libxml for serialization instead of builder.
        #
        # ==== Options
        # The +options+ parameter is handed off to the +to_xml_with_libxml+ method on each
        # attribute, so it has the same options as the +to_xml_with_libxml+ methods in
        # Active Support.
        #
        # * <tt>:dasherize</tt> - Boolean option to determine whether or not element names should
        #   replace underscores with dashes (default is <tt>false</tt>).
        # * <tt>:skip_instruct</tt> - Toggle skipping the +instruct!+ call on the XML builder
        #   that generates the XML declaration (default is <tt>false</tt>).
        #
        # ==== Examples
        #   my_group = SubsidiaryGroup.find(:first)
        #   my_group.to_xml
        #   # => <?xml version="1.0" encoding="UTF-8"?>
        #   #    <subsidiary_group> [...] </subsidiary_group>
        #
        #   my_group.to_xml(:dasherize => true)
        #   # => <?xml version="1.0" encoding="UTF-8"?>
        #   #    <subsidiary-group> [...] </subsidiary-group>
        #
        #   my_group.to_xml(:skip_instruct => true)
        #   # => <subsidiary_group> [...] </subsidiary_group>
        def to_xml(options={})
          attributes.to_xml_with_libxml({:root => self.class.element_name}.merge(options))
        end
      end

      module Formats
        module XmlFormat
          def encode(hash, options={})
            hash.to_xml_with_libxml(options)
          end
        end
      end
    end
  end
end

module ActiveResource
  module Formats
    XmlFormat.class_eval do
      remove_method :encode
      include Narnach::RailsExt::ActiveResource::Formats::XmlFormat
    end
  end
  
  Base.class_eval do
    remove_method :to_xml
    include Narnach::RailsExt::ActiveResource::Base
  end
end
