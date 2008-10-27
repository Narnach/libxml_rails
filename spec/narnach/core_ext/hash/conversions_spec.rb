require File.dirname(__FILE__) + '/../../../spec_helper'
require 'narnach/core_ext/hash/conversions'

describe Hash, '#to_xml' do
  it "should default to not dasherize data" do
    expected_xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<hash>
  <post_id type="integer">1</post_id>
</hash>
    XML
    {:post_id=>1}.to_xml.should == expected_xml
  end
  
  it 'should allow dasherizing the data' do
    expected_xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<hash>
  <post-id type="integer">1</post-id>
</hash>
    XML
    {:post_id=>1}.to_xml(:dasherize => true).should == expected_xml
  end
end

describe Hash, "#to_xml_with_libxml" do
  it "should convert a Hash with one element" do
    hsh = {:one => 1}
    libxml_xml = hsh.to_xml_with_libxml.to_s
    builder_xml = hsh.to_xml
    libxml_xml.should == builder_xml
  end

  it "should convert a Hash with nested Hash" do
    hsh = {:one => 1, 'two' => { :three => 3}}
    libxml_xml = hsh.to_xml_with_libxml.to_s
    builder_xml = hsh.to_xml
    libxml_xml.should == builder_xml
  end

  # These tests are adapted from the Rails ActiveSupport tests, so test to_xml_with_libxml in the same situations as to_xml
  describe 'ActiveSupport tests' do
    before(:each) do
      @builder_xml_options = { :root => :person, :skip_instruct => true }
      @libxml_options = { :root => :person, :skip_instruct => true }
    end

    def compare_with_rails_for(hash, custom_builder_options={}, custom_libxml_options={})
      builder_xml = hash.to_xml(@builder_xml_options.merge(custom_builder_options))
      libxml_xml = hash.to_xml_with_libxml(@libxml_options.merge(custom_libxml_options))
      libxml_xml.should == builder_xml
    end

    it 'should pass test_one_level' do
      compare_with_rails_for({ :name => "David", :street => "Paulina" })
    end

    it 'should pass test_one_level_dasherize_false' do
      compare_with_rails_for({ :name => "David", :street_name => "Paulina" }, {:dasherize => false}, {:dasherize => false})
    end

    it 'should pass test_one_level_dasherize_true' do
      compare_with_rails_for({ :name => "David", :street_name => "Paulina" }, {:dasherize => true}, {:dasherize => true})
    end
    
    it 'should pass test_one_level_with_types' do
      compare_with_rails_for({ :name => "David", :street => "Paulina", :age => 26, :age_in_millis => 820497600000, :moved_on => Date.new(2005, 11, 15), :resident => :yes })
    end

    it 'should pass test_one_level_with_nils' do
      compare_with_rails_for({ :name => "David", :street => "Paulina", :age => nil })
    end

    it 'should pass test_one_level_with_skipping_types' do
      compare_with_rails_for({ :name => "David", :street => "Paulina", :age => nil }, {:skip_types => true}, {:skip_types => true})
    end
    
    it 'should pass test_one_level_with_yielding' do
      hash = { :name => "David", :street => "Paulina" }
      builder_xml = hash.to_xml(@builder_xml_options) do |x|
        x.creator("Rails")
      end
      libxml_xml = hash.to_xml_with_libxml(@libxml_options) do |x|
        x << LibXML::XML::Node.new('creator', 'Rails')
      end
      libxml_xml.should == builder_xml
    end
  end
end
