module Narnach #:nodoc:
  module CoreExtensions #:nodoc:
    module Hash #:nodoc:
      module Conversions
        XML_TYPE_NAMES = ActiveSupport::CoreExtensions::Hash::Conversions::XML_TYPE_NAMES unless defined?(XML_TYPE_NAMES)
        XML_FORMATTING = ActiveSupport::CoreExtensions::Hash::Conversions::XML_FORMATTING unless defined?(XML_FORMATTING)

        # Version of #to_xml copy-adjusted from ActiveSupport to work with libxml.
        # 
        # Options supported in XMLBuilder that are/will be supported here:
        # - :root, name of root node. Default to hash
        # - :children, name of child nodes. Default to singular of root.
        # - :skip_types
        #
        # Options supported in a different way:
        # - :builder. Holds the active LibXML::XML::Document or LibXML::XML::Node.
        # - :skip_instruct. Determine if the document encoding needs to be set. When false, a new Document is created and used as :builder. When true a new Node is created when no :builder is specified.
        # - :dasherize, dasherize the node names or keep them as-is.
        #
        # Options known but not (yet) supported:
        # - :indent, default to level 2
        #
        # Uses Builder's String#to_xs for escaping
        def to_xml_with_libxml(options = {})
          options.reverse_merge!({:root => "hash", :to_string => true })
          dasherize = !options.has_key?(:dasherize) || options[:dasherize]
          root = dasherize ? options[:root].to_s.dasherize : options[:root].to_s
          to_string = options.delete(:to_string)
          skip_instruct = options.delete(:skip_instruct)
          doc = nil
          if skip_instruct
            node = LibXML::XML::Node.new(root)
            doc = node
            case options[:builder]
            when LibXML::XML::Document
              options[:builder].root << node
            when nil
              options[:builder] = node
            else
              options[:builder] << node
            end
          else
            options[:builder] = LibXML::XML::Document.new
            options[:builder].encoding = 'UTF-8'
            options[:builder].root = LibXML::XML::Node.new(root)
            doc = options[:builder].root
          end
          self.each do |key, value|
            case value
            when ::Hash
              value.to_xml_with_libxml(options.merge({ :root => key, :skip_instruct => true, :to_string => false, :builder => doc }))
            when ::Array
              value.to_xml_with_libxml(options.merge({ :root => key, :children => key.to_s.singularize, :skip_instruct => true, :to_string => false, :builder => doc}))
            # when ::Method, ::Proc
            else
              if value.respond_to?(:to_xml_with_libxml)
                value.to_xml_with_libxml(options.merge({ :root => key, :skip_instruct => true, :to_string => false, :builder => doc }))
              else
                type_name = XML_TYPE_NAMES[value.class.name]
                key = dasherize ? key.to_s.dasherize : key.to_s
                attributes = options[:skip_types] || value.nil? || type_name.nil? ? { } : { :type => type_name }
                if value.nil?
                  attributes[:nil] = true
                end

                content = XML_FORMATTING[type_name] ? XML_FORMATTING[type_name].call(value) : value
                child = LibXML::XML::Node.new(key, content.to_s.to_xs)
                attributes.stringify_keys.each do |akey, avalue|
                  child[akey] = String(avalue).to_s.to_xs
                end
                doc << child
              end # if
            end # case
          end # each
          yield options[:builder] if block_given?
          if to_string
            string = options[:builder].to_s
            string << "\n" if skip_instruct # Emulate Builder behaviour
            return string
          else
            return options[:builder]
          end
        end # to_xml_with_libxml
      end # module Conversions
    end # module Hash
  end # module CoreExtensions
end # module Narnach

class Hash
  include Narnach::CoreExtensions::Hash::Conversions
end
