require 'spec_helper'
require 'logger'

describe Fozzie do
  it "flunks this deliberately failing spec" do
    true.should be_false
  end
    
  it "allows dynamic assignment" do
    { :host => 'somewhere.local', :port => 99 }.each do |field, val|
      Fozzie.configure {|c| c.send("#{field}=", val) }
      Fozzie.c.send(field).should == val
    end
  end

  describe ".logger" do
    let(:logger) { double "logger" }

    before do
      @old_logger = Fozzie.logger
    end
    
    it "assigns a logger" do
      Fozzie.logger = logger
      Fozzie.logger.should eq logger
    end

    after do
      Fozzie.logger = @old_logger
    end
  end

  it "has configuration" do
    Fozzie.config.should be_kind_of(Fozzie::Configuration)
    Fozzie.c.should be_kind_of(Fozzie::Configuration)
  end

  it "creates new classes for statistics gathering" do
    Fozzie.c.namespaces.each do |k|
      Kernel.const_defined?(k).should == true
    end
  end
end
