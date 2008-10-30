require 'activesupport'
require 'libxml'

module Narnach #:nodoc:
  module CoreExtensions #:nodoc:
    module Array #:nodoc:
      module Conversions
        # Version of #to_xml copy-adjusted from ActiveSupport to work with libxml.
        # 
        # Options not supported:
        # - :indent
        def to_xml_with_libxml(options = {})
          raise "Not all elements respond to to_xml" unless all? { |e| e.respond_to? :to_xml_with_libxml }
          options.reverse_merge!({:to_string => true, :skip_instruct => false })
          dasherize = !options.has_key?(:dasherize) || options[:dasherize]
          options[:root]     ||= all? { |e| e.is_a?(first.class) && first.class.to_s != "Hash" } ? first.class.to_s.underscore.pluralize : "records"
          options[:root]     = options[:root].to_s.dasherize if dasherize
          options[:children] ||= options[:root].singularize
          to_string = options.delete(:to_string)
          skip_instruct = options.delete(:skip_instruct)
          root     = options.delete(:root).to_s
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
          doc['type'] = 'array' unless options[:skip_types]


          children = options.delete(:children)
          opts = options.merge({ :root => children })

          unless empty?
            yield doc if block_given?
            each do |e|
              e.to_xml_with_libxml(opts.merge!({ :skip_instruct => true, :to_string => false, :builder => doc }))
            end
          end
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

class Array
  include Narnach::CoreExtensions::Array::Conversions
end
