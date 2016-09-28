require 'spec_helper'
require 'fozzie/adapter/datadog'

module Fozzie::Adapter
  describe Datadog do
    it_behaves_like "fozzie adapter"

    # Switch to Statsd adapter for the duration of this test
    before(:all) do
      Fozzie.c.adapter = :Datadog
    end

    after(:all) do
      Fozzie.c.adapter = :TestAdapter
    end

    describe "#register" do
      it "appends tags to the metrics" do
        subject.should_receive(:send_to_socket).with(%r{\|#country:usa,testing$})

        subject.register(:bucket => "foo", :value => 1, :type => :gauge, :sample_rate => 1, tags: ['country:usa','testing'])
      end

      it "does not append tags when none are specified" do
        subject.should_receive(:send_to_socket).with(%r{foo:1\|g$})

        subject.register(:bucket => "foo", :value => 1, :type => :gauge, :sample_rate => 1)
      end
    end
  end
end
