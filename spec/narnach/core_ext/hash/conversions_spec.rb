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
end
