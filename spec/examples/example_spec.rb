require File.dirname(__FILE__) + '/../spec_helper'
require "open-uri"

describe "basic" do
  before(:each) do
    reset!
    PoolParty::Script.inflate open(File.dirname(__FILE__) + "/basic.rb").read
  end
  it "should have one pool called :app" do
    pool(:app).should_not be_nil
  end
  it "should have a cloud called :app" do
    pool(:app).cloud(:app).should_not be_nil
  end
  it "should have a cloud called :db" do
    pool(:app).cloud(:db).should_not be_nil
  end
  it "should set the minimum_instances on the cloud to 2 (overriding the pool options)" do
    pool(:app).cloud(:app).minimum_instances.should == 2
  end
  it "should set the maximum_instances on the cloud to 5" do
    pool(:app).cloud(:app).maximum_instances.should == 5
  end
  it "should set the minimum_instances on the db cloud to 3" do
    pool(:app).cloud(:db).minimum_instances.should == 3
  end  
end
describe "with_apache_plugin" do
  before(:each) do
    reset!
    PoolParty::Script.inflate(open(File.dirname(__FILE__) + "/with_apache_plugin.rb").read, File.dirname(__FILE__))
  end
  it "should have one pool called :app" do
    pool(:app).should_not be_nil
  end
  it "should have a cloud called :app" do
    pool(:app).cloud(:app).should_not be_nil
  end
  it "should have a cloud called :db" do
    pool(:app).cloud(:db).should_not be_nil
  end
  it "should set the minimum_instances on the cloud to 2 (overriding the pool options)" do
    pool(:app).cloud(:app).minimum_instances.should == 2
  end
  it "should set the maximum_instances on the cloud to 5" do
    pool(:app).cloud(:app).maximum_instances.should == 10
  end
  it "should set the minimum_instances on the db cloud to 3" do
    pool(:app).cloud(:db).minimum_instances.should == 2
  end
  describe "apache plugin" do
    before(:each) do
      @c = pool(:app).cloud(:app)
    end
    it "should have apache as the ApacheClas" do
      @c.apache.class.should == ApacheClas
    end
    it "should set php == true on the apache plugin" do
      @c.apache.enable_php
      @c.apache.php.should == true
    end
  end
end