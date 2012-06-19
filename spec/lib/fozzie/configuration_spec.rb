require 'spec_helper'
require 'resolv'

describe Fozzie::Configuration do

  it "#host" do
    subject.host.should be_kind_of(String)
  end

  it "#port" do
    subject.port.should be_kind_of(Fixnum)
  end

  it "attempts to load configuration from yaml" do
    c = Fozzie::Configuration.new({:env => 'test', :config_path => 'spec/'})
    c.stubs(:origin_name).returns ""
    c.host.should eq '1.1.1.1'
    c.port.should eq 9876
    c.appname.should eq 'fozzie'
    c.data_prefix.should eq 'fozzie.test'
  end

  it "defaults env" do
    subject.env.should eq 'test'
  end

  it "creates a data prefix" do
    subject.stubs(:origin_name).returns("")
    subject.data_prefix.should eq 'test'
  end

  it "creates a data prefix with appname when set" do
    subject.stubs(:origin_name).returns("")
    subject.appname = 'astoria'
    subject.data_prefix.should eq 'astoria.test'
  end

  it "creates a prefix with origin" do
    subject.appname = 'astoria'
    subject.data_prefix.should match /^astoria\.(\S+)\.test$/
  end

  it "handles missing configuration namespace" do
    proc { Fozzie::Configuration.new({:env => 'blbala', :config_path => 'spec/'}) }.should_not raise_error
  end

  it "#namespaces" do
    subject.namespaces.should be_kind_of(Array)
    subject.namespaces.should include("Stats")
    subject.namespaces.should include("S")
  end

  describe "#sniff?" do

    it "defaults to false for testing" do
      subject.stubs(:env).returns('test')
      subject.sniff?.should be_false
    end

    it "defaults true when in development" do
      subject.stubs(:env).returns('development')
      subject.sniff?.should be_true
    end

    it "defaults true when in production" do
      subject.stubs(:env).returns('production')
      subject.sniff?.should be_true
    end

  end

  describe "#sniff_envs allows configuration for #sniff?" do
    let!(:sniff_envs) { subject.stubs(:sniff_envs).returns(['test']) }

    it "scopes to return false" do
      subject.stubs(:env).returns('development')
      subject.sniff?.should be_false
    end

    it "scopes to return true" do
      subject.stubs(:env).returns('test')
      subject.sniff?.should be_true
    end

  end

end