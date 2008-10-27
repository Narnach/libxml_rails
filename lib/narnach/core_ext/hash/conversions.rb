require 'activesupport'
require 'libxml'

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

        # Options supported in XMLBuilder that are/will be supported here:
        # - :root, name of root node. Default to hash
        # - :children, name of child nodes. Default to singular of root.
        # - :skip_types
        #
        # Options supported in a different way:
        # - :builder. Holds the active LibXML::XML::Document or LibXML::XML::Node.
        # - :skip_instruct. Determine if the document encoding needs to be set. Probably only applies to Document.
        # - :dasherize, dasherize the node names or keep them as-is. Defaults to false instead of true.
        #
        # Options known but not (yet) supported:
        # - :indent, default to level 2
        def to_xml_with_libxml(options = {})
          options.reverse_merge!({ :builder => LibXML::XML::Document.new, :root => "hash", :dahserize => false })
          dasherize = options[:dasherize]
          doc = options[:builder]
          root = dasherize ? options[:root].to_s.dasherize : options[:root].to_s
          unless options.delete(:skip_instruct)
            doc.encoding = 'UTF-8'
            doc.root = LibXML::XML::Node.new(root)
            doc = doc.root
          end
          self.each do |key, value|
            case value
            when ::Hash
            # when ::Array
            # when ::Method, ::Proc
            else
              if value.respond_to?(:to_xml_with_libxml)
                value.to_xml_with_libxml(options.merge({ :root => key, :skip_instruct => true }))
              else
                type_name = ActiveSupport::CoreExtensions::Hash::Conversions::XML_TYPE_NAMES[value.class.name]
                key = dasherize ? key.to_s.dasherize : key.to_s
                attributes = options[:skip_types] || value.nil? || type_name.nil? ? { } : { :type => type_name }
                if value.nil?
                  attributes[:nil] = true
                end

                child = LibXML::XML::Node.new(key, ActiveSupport::CoreExtensions::Hash::Conversions::XML_FORMATTING[type_name] ? ActiveSupport::CoreExtensions::Hash::Conversions::XML_FORMATTING[type_name].call(value) : value)
                attributes.stringify_keys.each do |akey, avalue|
                  child[akey] = avalue
                end
                doc << child
              end # if
            end # case
          end # each
          yield options[:builder] if block_given?
          return options[:builder]
        end # to_xml_with_libxml
      end # module Conversions
    end # module Hash
  end # module CoreExtensions
end # module Narnach

class Hash
  include Narnach::CoreExtensions::Hash::Conversions
end
