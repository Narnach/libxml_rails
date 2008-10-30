require File.dirname(__FILE__) + '/spec_helper'

describe Hash, '.from_xml' do
  
  before(:each) do
    @xml_options = { :root => :person, :skip_instruct => true, :indent => 0 }
  end
  
  it 'parses a single record' do
    topic_xml = <<-EOT
      <topic>
        <title>The First Topic</title>
        <author-name>David</author-name>
        <id type="integer">1</id>
        <approved type="boolean"> true </approved>
        <replies-count type="integer">0</replies-count>
        <replies-close-in type="integer">2592000000</replies-close-in>
        <written-on type="date">2003-07-16</written-on>
        <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
        <content type="yaml">--- \n1: should be an integer\n:message: Have a nice day\narray: \n- should-have-dashes: true\n  should_have_underscores: true\n</content>
        <author-email-address>david@loudthinking.com</author-email-address>
        <parent-id></parent-id>
        <ad-revenue type="decimal">1.5</ad-revenue>
        <optimum-viewing-angle type="float">135</optimum-viewing-angle>
        <resident type="symbol">yes</resident>
      </topic>
    EOT

    expected_topic_hash = {
      :title => "The First Topic",
      :author_name => "David",
      :id => 1,
      :approved => true,
      :replies_count => 0,
      :replies_close_in => 2592000000,
      :written_on => Date.new(2003, 7, 16),
      :viewed_at => Time.utc(2003, 7, 16, 9, 28),
      :content => { :message => "Have a nice day", 1 => "should be an integer", "array" => [{ "should-have-dashes" => true, "should_have_underscores" => true }] },
      :author_email_address => "david@loudthinking.com",
      :parent_id => nil,
      :ad_revenue => BigDecimal("1.50"),
      :optimum_viewing_angle => 135.0,
      :resident => :yes
    }.stringify_keys
 
    Hash.from_xml(topic_xml)["topic"].should == expected_topic_hash
  end
  
  it 'parses a single record with nil values' do
    topic_xml = <<-EOT
      <topic>
        <title></title>
        <id type="integer"></id>
        <approved type="boolean"></approved>
        <written-on type="date"></written-on>
        <viewed-at type="datetime"></viewed-at>
        <content type="yaml"></content>
        <parent-id></parent-id>
      </topic>
    EOT
    
    expected_topic_hash = {
      :title      => nil, 
      :id         => nil,
      :approved   => nil,
      :written_on => nil,
      :viewed_at  => nil,
      :content    => nil, 
      :parent_id  => nil
    }.stringify_keys
    
    Hash.from_xml(topic_xml)["topic"].should == expected_topic_hash
  end
  
  it 'parses multiple records' do
    topics_xml = <<-EOT
      <topics type="array">
        <topic>
          <title>The First Topic</title>
          <author-name>David</author-name>
          <id type="integer">1</id>
          <approved type="boolean">false</approved>
          <replies-count type="integer">0</replies-count>
          <replies-close-in type="integer">2592000000</replies-close-in>
          <written-on type="date">2003-07-16</written-on>
          <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
          <content>Have a nice day</content>
          <author-email-address>david@loudthinking.com</author-email-address>
          <parent-id nil="true"></parent-id>
        </topic>
        <topic>
          <title>The Second Topic</title>
          <author-name>Jason</author-name>
          <id type="integer">1</id>
          <approved type="boolean">false</approved>
          <replies-count type="integer">0</replies-count>
          <replies-close-in type="integer">2592000000</replies-close-in>
          <written-on type="date">2003-07-16</written-on>
          <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
          <content>Have a nice day</content>
          <author-email-address>david@loudthinking.com</author-email-address>
          <parent-id></parent-id>
        </topic>
      </topics>
    EOT
    
    expected_topic_hash = {
      :title => "The First Topic",
      :author_name => "David",
      :id => 1,
      :approved => false,
      :replies_count => 0,
      :replies_close_in => 2592000000,
      :written_on => Date.new(2003, 7, 16),
      :viewed_at => Time.utc(2003, 7, 16, 9, 28),
      :content => "Have a nice day",
      :author_email_address => "david@loudthinking.com",
      :parent_id => nil
    }.stringify_keys
    
    Hash.from_xml(topics_xml)["topics"].first.should == expected_topic_hash
  end
  
  it 'parses a single record with attributes *other* than "type"' do
    topic_xml = <<-EOT
    <rsp stat="ok">
      <photos page="1" pages="1" perpage="100" total="16">
        <photo id="175756086" owner="55569174@N00" secret="0279bf37a1" server="76" title="Colored Pencil PhotoBooth Fun" ispublic="1" isfriend="0" isfamily="0"/>
      </photos>
    </rsp>
    EOT
    
    expected_topic_hash = {
      :id => "175756086",
      :owner => "55569174@N00",
      :secret => "0279bf37a1",
      :server => "76",
      :title => "Colored Pencil PhotoBooth Fun",
      :ispublic => "1",
      :isfriend => "0",
      :isfamily => "0",
    }.stringify_keys
    
    Hash.from_xml(topic_xml)["rsp"]["photos"]["photo"].should == expected_topic_hash
  end
  
  it 'parses an empty array' do
   blog_xml = <<-XML
     <blog>
       <posts type="array"></posts>
     </blog>
   XML
   expected_blog_hash = {"blog" => {"posts" => []}}
   Hash.from_xml(blog_xml).should == expected_blog_hash
  end
  
  it 'parses an empty array with whitespace' do
    blog_xml = <<-XML
      <blog>
        <posts type="array">
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => []}}
    Hash.from_xml(blog_xml).should == expected_blog_hash
  end
  
  it 'parses an array with one entry' do
    blog_xml = <<-XML
      <blog>
        <posts type="array">
          <post>a post</post>
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => ["a post"]}}
    Hash.from_xml(blog_xml).should == expected_blog_hash
  end
  
  it 'parses an array with multiple entries' do
    blog_xml = <<-XML
      <blog>
        <posts type="array">
          <post>a post</post>
          <post>another post</post>
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => ["a post", "another post"]}}
    Hash.from_xml(blog_xml).should == expected_blog_hash
  end
  
  it 'parses a file' do
    blog_xml = <<-XML
      <blog>
        <logo type="file" name="logo.png" content_type="image/png">
        </logo>
      </blog>
    XML
    hash = Hash.from_xml(blog_xml)
    hash.has_key?('blog').should be_true
    hash['blog'].has_key?('logo').should be_true
    
    file = hash['blog']['logo']
    file.original_filename.should == 'logo.png'
    file.content_type.should == 'image/png'
  end
  
  it 'parses a file with defaults' do
    blog_xml = <<-XML
      <blog>
        <logo type="file">
        </logo>
      </blog>
    XML
    file = Hash.from_xml(blog_xml)['blog']['logo']
    file.original_filename.should == 'untitled'
    file.content_type.should == 'application/octet-stream'
  end
  
  it 'parses XSD-like types' do
    bacon_xml = <<-EOT
    <bacon>
      <weight type="double">0.5</weight>
      <price type="decimal">12.50</price>
      <chunky type="boolean"> 1 </chunky>
      <expires-at type="dateTime">2007-12-25T12:34:56+0000</expires-at>
      <notes type="string"></notes>
      <illustration type="base64Binary">YmFiZS5wbmc=</illustration>
    </bacon>
    EOT
    
    expected_bacon_hash = {
      :weight => 0.5,
      :chunky => true,
      :price => BigDecimal("12.50"),
      :expires_at => Time.utc(2007,12,25,12,34,56),
      :notes => "",
      :illustration => "babe.png"
    }.stringify_keys
    
    Hash.from_xml(bacon_xml)["bacon"].should == expected_bacon_hash
  end
  
  it 'trickles the "type" attribute through, when unknown' do
    product_xml = <<-EOT
    <product>
      <weight type="double">0.5</weight>
      <image type="ProductImage"><filename>image.gif</filename></image>
      
    </product>
    EOT
    
    expected_product_hash = {
      :weight => 0.5,
      :image => {'type' => 'ProductImage', 'filename' => 'image.gif' },
    }.stringify_keys
    
    Hash.from_xml(product_xml)["product"].should == expected_product_hash
  end
  
  it 'unescapes text nodes' do
    xml_string = '<person><bare-string>First &amp; Last Name</bare-string><pre-escaped-string>First &amp;amp; Last Name</pre-escaped-string></person>'
    expected_hash = { 
      :bare_string        => 'First & Last Name', 
      :pre_escaped_string => 'First &amp; Last Name'
    }.stringify_keys
    Hash.from_xml(xml_string)['person'].should == expected_hash
  end
  
  it 'parses Hash.to_xml output' do
    hash = { 
      :bare_string        => 'First & Last Name', 
      :pre_escaped_string => 'First &amp; Last Name'
    }.stringify_keys
    
    Hash.from_xml(hash.to_xml(@xml_options))['person'].should == hash
  end
  
  it 'parses a datetime with UTC time' do
    alert_xml = <<-XML
      <alert>
        <alert_at type="datetime">2008-02-10T15:30:45Z</alert_at>
      </alert>
    XML
    alert_at = Hash.from_xml(alert_xml)['alert']['alert_at']
    alert_at.utc?.should be_true
    alert_at.should == Time.utc(2008, 2, 10, 15, 30, 45)
  end
  
  it 'parses a datetime with non-UTC time' do
    alert_xml = <<-XML
      <alert>
        <alert_at type="datetime">2008-02-10T10:30:45-05:00</alert_at>
      </alert>
    XML
    alert_at = Hash.from_xml(alert_xml)['alert']['alert_at']
    alert_at.utc?.should be_true
    alert_at.should == Time.utc(2008, 2, 10, 15, 30, 45)
  end
  
  it 'parses a datetime with a far-future date' do
     alert_xml = <<-XML
       <alert>
         <alert_at type="datetime">2050-02-10T15:30:45Z</alert_at>
       </alert>
     XML
     alert_at = Hash.from_xml(alert_xml)['alert']['alert_at']
     alert_at.utc?.should be_true
     alert_at.year.should   == 2050
     alert_at.month.should  == 2
     alert_at.day.should    == 10
     alert_at.hour.should   == 15
     alert_at.min.should    == 30
     alert_at.sec.should    == 45
  end
end
