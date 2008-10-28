require File.dirname(__FILE__) + '/../../../spec_helper'
require 'narnach/core_ext/array/conversions'

describe Array, '#to_xml' do
  describe 'ActiveSupport tests' do
    before(:each) do
      @builder_xml_options = {:skip_instruct => true }
      @libxml_options = {:skip_instruct => true }
    end

    def compare_with_rails_for(hash, options = {})
      builder_xml = hash.to_xml(@builder_xml_options.merge(options))
      libxml_xml = hash.to_xml_with_libxml(@libxml_options.merge(options))
      libxml_xml.should == builder_xml
    end

    it 'should pass test_to_xml' do
      compare_with_rails_for([
        { :name => "David", :age => 26, :age_in_millis => 820497600000 },
        { :name => "Jason", :age => 31, :age_in_millis => BigDecimal.new('1.0') }
      ])
    end
    
    it 'should pass test_to_xml_with_dedicated_name' do
      compare_with_rails_for([
        { :name => "David", :age => 26, :age_in_millis => 820497600000 }, { :name => "Jason", :age => 31 }
      ],{:root => "people"})
    end
    
    it 'should pass test_to_xml_with_options' do
      compare_with_rails_for([
        { :name => "David", :street_address => "Paulina" }, { :name => "Jason", :street_address => "Evergreen" }
      ], {:skip_types => true})
    end

    it 'should pass test_to_xml_with_dasherize_false' do
      compare_with_rails_for([
        { :name => "David", :street_address => "Paulina" }, { :name => "Jason", :street_address => "Evergreen" }
      ], {:skip_types => true, :dasherize => false})
    end

    it 'should pass test_to_xml_with_dasherize_true' do
      compare_with_rails_for([
        { :name => "David", :street_address => "Paulina" }, { :name => "Jason", :street_address => "Evergreen" }
      ], {:skip_types => true, :dasherize => true})
    end

    it 'should pass test_to_with_instruct' do
      compare_with_rails_for([
        { :name => "David", :age => 26, :age_in_millis => 820497600000 },
        { :name => "Jason", :age => 31, :age_in_millis => BigDecimal.new('1.0') }
      ], {:skip_instruct => false})
    end

    it 'should pass test_to_xml_with_block' do
      ary = [
        { :name => "David", :age => 26, :age_in_millis => 820497600000 },
        { :name => "Jason", :age => 31, :age_in_millis => BigDecimal.new('1.0') }
      ]
      builder_xml = ary.to_xml(@builder_xml_options) do |builder|
        builder.count 2
      end
      libxml_xml = ary.to_xml_with_libxml(@libxml_options) do |libxml|
        libxml << LibXML::XML::Node.new('count', 2)
      end
      libxml_xml.should == builder_xml
    end
    
    it 'should pass test_to_xml_with_empty' do
      compare_with_rails_for([])
    end
  end
end
