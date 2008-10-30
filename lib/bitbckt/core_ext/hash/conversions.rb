require 'active_support'
require 'libxml'

module Bitbckt #:nodoc:
  module CoreExtensions #:nodoc:
    module Hash #:nodoc:
      module Conversions
        
        def self.included(klass)
          klass.extend(ClassMethods)
        end
        
        module ClassMethods
          def from_xml(xml)
            result = LibXML::XML::Parser.string(xml).parse
            if result.root.attributes['type'] == 'array'
              { result.root.name.to_s.gsub(/-/,'_') => array_from_node(result.root) }
            else
              { result.root.name.to_s.gsub(/-/,'_') => xml_node_to_hash(result.root) }
            end
          end     

          private
            def xml_node_to_hash(node)              
              # If we are at an XML::Node, build the Hash
              if node.element?
                result_hash = {}
                if node.children?
                  
                  node.each_child do |child|
                    next if child.empty?
                  
                    if child.attributes['type'] == 'array'
                      result = array_from_node(child)
                    elsif child.attributes['type'] == 'string' and child.children.empty?
                      # NOTE: Odd issue with libxml - XML::Node#empty? returns false and
                      #       XML::Node#children? returns true when the Node contains just
                      #       an empty string (#children == []), but has attributes.
                      result = ''
                    elsif child.attributes['type'] == 'file'
                      result = Object::Hash::XML_PARSING['file'].call(child.content.to_s, child.attributes)
                    elsif Object::Hash::XML_PARSING.include? child.attributes['type'] and not child.content.to_s.chomp.blank?
                      result = Object::Hash::XML_PARSING[child.attributes['type']].call(child.content.to_s)
                    else
                      result = xml_node_to_hash(child)
                      result['type'] = child.attributes['type'] if child.attributes['type'] and result
                    end
                    
                    return result if child.name == 'text'
                    
                    key = child.name.gsub(/-/, '_')
                    if result_hash[key]
                      if result_hash[key].is_a?(Object::Array)
                        result_hash[key] << result
                      else
                        result_hash[key] = [result_hash[key]] << result
                      end
                    else
                      result_hash[key] = result
                    end
                  end
                
                else
                  if node.attributes['type'] || node.attributes.length == 0 || node.attributes['nil'] == 'true'
                    result_hash = nil
                  else
                    node.each_attr do |attribute|
                      result_hash[attribute.name] = attribute.value.to_s
                    end
                  end
                end
                
                return result_hash
              else
                return node.content.to_s
              end              
            end
          
            def array_from_node(node)
              returning([]) do |collection|
                node.each_child do |child|
                  next if child.empty?
                  collection << xml_node_to_hash(child)
                end
              end
            end
        end
        
      end
    end
  end
end

Hash.class_eval { include Bitbckt::CoreExtensions::Hash::Conversions }