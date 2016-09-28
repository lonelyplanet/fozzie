require 'spec_helper'
require 'fozzie/adapter/statsd'

module Fozzie::Adapter
  describe Statsd do
    it_behaves_like "fozzie adapter"

    # Switch to Statsd adapter for the duration of this test
    before(:all) do
      Fozzie.c.adapter = :Statsd
    end

    after(:all) do
      Fozzie.c.adapter = :TestAdapter
    end
    
    it "downcases any stat value" do
      subject.should_receive(:send_to_socket).with(/\.foo/)

      subject.register(:bucket => "FOO", :value => 1, :type => :gauge, :sample_rate => 1)
    end

    describe "#format_bucket" do
      it "accepts arrays" do
        subject.format_bucket([:foo, '2']).should match(/foo.2$/)
        subject.format_bucket([:foo, '2']).should match(/foo.2$/)
        subject.format_bucket(%w{foo bar}).should match(/foo.bar$/)
      end

      it "converts any values to strings for stat value, ignoring nil" do
        subject.format_bucket([:foo, 1, nil, "@", "BAR"]).should =~ /foo.1._.bar/
      end

      it "replaces invalid chracters" do
        subject.format_bucket([:foo, ':']).should match(/foo.#{subject.class::RESERVED_CHARS_REPLACEMENT}$/)
        subject.format_bucket([:foo, '@']).should match(/foo.#{subject.class::RESERVED_CHARS_REPLACEMENT}$/)
        subject.format_bucket('foo.bar.|').should match(/foo.bar.#{subject.class::RESERVED_CHARS_REPLACEMENT}$/)
      end
    end

    describe "#format_value" do
      it "defaults type to gauge when type is not mapped" do
        subject.format_value(1, :foo, 1).should eq '1|g'
      end

      it "converts basic values to string" do
        subject.format_value(1, :count, 1).should eq '1|c'
      end
    end

    it "ensures block is called on socket error" do
      subject.socket.stub(:send) { raise SocketError }

      proc { subject.register(:bucket => 'data.bin', :value => 1, :type => :gauge, :sample_rate => 1) { sleep 0.01 } }.should_not raise_error
      proc { subject.register(:bucket => 'data.bin', :value => 1, :type => :gauge, :sample_rate => 1) { sleep 0.01 } }.should_not raise_error
    end

    it "raises Timeout on slow lookup" do
      Fozzie.c.timeout = 0.01
      subject.socket.stub(:send).with(any_args) { sleep 0.4 }

      subject.register(:bucket => 'data.bin', :value => 1, :type => :gauge, :sample_rate => 1).should eq false
    end

    describe "multiple stats in a single call" do

      it "collects stats together with delimeter" do
        Fozzie.c.disable_prefix

        stats = [
          { :bucket => 'foo', :value => 1, :type => :count, :sample_rate => 1 },
          { :bucket => 'bar', :value => 1, :type => :gauge, :sample_rate => 1 },
          { :bucket => %w{foo bar}, :value => 100, :type => :timing, :sample_rate => 1 }
        ]

        subject.should_receive(:send_to_socket).with "foo:1|c\nbar:1|g\nfoo.bar:100|ms"

        subject.register(stats)
      end
    end
  end
end
