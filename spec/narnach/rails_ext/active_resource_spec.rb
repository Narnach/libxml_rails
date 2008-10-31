require File.dirname(__FILE__) + '/../../spec_helper'
require 'libxml_rails/active_resource'

class SomePerson < ActiveResource::Base
  self.site = 'http://example.org'
end

describe ActiveResource, '#to_xml' do
  before(:each) do
    @sp = SomePerson.new(:name => 'Wes', :last_name => 'Oldenbeuving', :age => 22)
  end

  it "should return the resource as XML" do
    @sp.to_xml(:libxml=>false).should == @sp.to_xml(:libxml=>true)
  end
end
