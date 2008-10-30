require File.dirname(__FILE__) + '/../../../spec_helper'

describe Hash, '#from_xml' do
  it "should undasherize the Hash keys" do
    xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<post>
  <post-id type="integer">1</post-id>
</post>
    XML
    Hash.from_xml(xml).should == {'post' => {'post_id' => 1}}
  end
  
  # # libxml will not break, but it takes about 140MB and 60 seconds on a 2.4GHz Core2 Duo Macbook to succeed.
  # # It would be nice if entity expansion could be disabled if you don't plan to use it.
  # it 'should pass test_expansion_count_is_limited' do
  #   attack_xml = <<-EOT
  #   <?xml version="1.0" encoding="UTF-8"?>
  #   <!DOCTYPE member [
  #     <!ENTITY a "&b;&b;&b;&b;&b;&b;&b;&b;&b;&b;">
  #     <!ENTITY b "&c;&c;&c;&c;&c;&c;&c;&c;&c;&c;">
  #     <!ENTITY c "&d;&d;&d;&d;&d;&d;&d;&d;&d;&d;">
  #     <!ENTITY d "&e;&e;&e;&e;&e;&e;&e;&e;&e;&e;">
  #     <!ENTITY e "&f;&f;&f;&f;&f;&f;&f;&f;&f;&f;">
  #     <!ENTITY f "&g;&g;&g;&g;&g;&g;&g;&g;&g;&g;">
  #     <!ENTITY g "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx">
  #   ]>
  #   <member>
  #   &a;
  #   </member>
  #   EOT
  #   lambda {
  #     Hash.from_xml(attack_xml)
  #   }.should_not raise_error
  # end
end

class IWriteMyOwnXML
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.level_one do
      xml.tag!(:second_level, 'content')
    end
  end
  
  def to_xml_with_libxml(options = {})
    {:second_level => 'content'}.to_xml_with_libxml(options.merge(:root => 'level_one', :dasherize => false))
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

    it 'should pass test_two_levels' do
      compare_with_rails_for({ :name => "David", :address => { :street => "Paulina" } })
    end

    it 'should pass test_two_levels_with_second_level_overriding_to_xml' do
      compare_with_rails_for({ :name => "David", :address => { :street => "Paulina" }, :child => IWriteMyOwnXML.new })
    end
    
    it 'should pass test_two_levels_with_array' do
      compare_with_rails_for({ :name => "David", :addresses => [{ :street => "Paulina" }, { :street => "Evergreen" }] })
    end

    it 'should test_three_levels_with_array' do
      compare_with_rails_for({ :name => "David", :addresses => [{ :streets => [ { :name => "Paulina" }, { :name => "Paulina" } ] } ] })
    end

    # The XML builder seems to fail miserably when trying to tag something
    # with the same name as a Kernel method (throw, test, loop, select ...)
    it 'should pass test_kernel_method_names_to_xml' do
      compare_with_rails_for({ :throw => { :ball => 'red' } })
    end

    it 'should pass test_escaping_to_xml' do
      compare_with_rails_for({ 
        :bare_string        => 'First & Last Name', 
        :pre_escaped_string => 'First &amp; Last Name'
      }.stringify_keys)
    end

    it 'should pass test_roundtrip_to_xml_from_xml' do
      hash = { 
        :bare_string        => 'First & Last Name', 
        :pre_escaped_string => 'First &amp; Last Name'
      }.stringify_keys

      Hash.from_xml(hash.to_xml_with_libxml(@libxml_options))['person'].should == hash
    end
  end
end
