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
    c = Fozzie::Configuration.new({
                                    env:         'test',
                                    config_path: 'spec/',
                                    adapter:     :TestAdapter
                                  })
    c.stub(:origin_name => "")
    c.host.should eq '1.1.1.1'
    c.port.should eq 9876
    c.appname.should eq 'fozzie'
    c.data_prefix.should eq "fozzie#{c.safe_separator}test"
    c.enable_rails_middleware.should be_false
  end

  it "defaults env" do
    subject.env.should eq 'test'
  end

  describe "#adapter" do
    it "throw error on incorrect assignment" do
      -> { Fozzie::Configuration.new({:env => 'test', :adapter => 'foo'}) }.should raise_error(Fozzie::AdapterMissing)
    end

    it "defaults adapter to Statsd" do
      subject.adapter.should be_kind_of(Fozzie::Adapter::Statsd)
    end
  end

  describe "#enable_rails_middleware" do
    it("should default to enabled") { subject.enable_rails_middleware.should be_true }
  end

  describe "#disable_prefix" do
    it "sets the data_prefix to nil" do
      subject.disable_prefix
      subject.data_prefix.should be_nil
    end
  end
  
  describe "#prefix and #data_prefix" do
    it "creates a #data_prefix" do
      subject.stub(:origin_name => "")
      subject.data_prefix.should eq 'test'
    end

    it "creates a #data_prefix with appname when set" do
      subject.stub(:origin_name => "")
      subject.appname = 'astoria'
      subject.data_prefix.should eq 'astoria.test'
    end

    it "creates a #data_prefix with origin" do
      subject.appname = 'astoria'
      subject.data_prefix.should match /^astoria\.(\S+)\.test$/
    end

    it "allows dynamic assignment of #prefix to derive #data_prefix" do
      subject.prefix = [:foo, :bar, :car]
      subject.data_prefix.should eq 'foo.bar.car'
    end

    it "allows dynamic injection of value to prefix" do
      subject.stub(:origin_name => "")
      subject.prefix << 'git-sha-1234'
      subject.data_prefix.should eq 'test.git-sha-1234'
    end
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
      subject.stub(:env => "test")
      subject.sniff?.should be_false
    end

    it "defaults true when in development" do
      subject.stub(:env => "development")
      subject.sniff?.should be_true
    end

    it "defaults true when in production" do
      subject.stub(:env => "production")
      subject.sniff?.should be_true
    end
  end

  describe "#sniff_envs allows configuration for #sniff?" do
    let!(:sniff_envs) { subject.stub(:sniff_envs => ['test']) }

    it "scopes to return false" do
      subject.stub(:env => "development")
      subject.sniff?.should be_false
    end

    it "scopes to return true" do
      subject.stub(:env => "test")
      subject.sniff?.should be_true
    end

  end

  describe "ignoring prefix" do
    it "does not use prefix when set to ignore" do
      subject.disable_prefix
      subject.ignore_prefix.should eq(true)
    end
  end

end
