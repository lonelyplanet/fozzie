require 'spec_helper'
require 'fozzie/interface'

describe Fozzie::Interface do

  subject { Fozzie::Interface.instance }

  it "acts an a singleton" do
    Fozzie.c.namespaces.each do |k|
      Kernel.const_get(k).should eq Fozzie::Interface.instance
    end
  end

  it "downcases any stat value" do
    subject.expects(:send_to_socket)
      .with {|bin| bin.match /\.foo/ }

    subject.increment("FOO")
  end

  it "replaces invalid stat value chars" do
    subject.expects(:send_to_socket)
      .with {|bin| bin.match /\.foo_/ }
      .times(4)

    subject.increment("FOO:")
    subject.increment("FOO@")
    subject.increment("FOO|")
    subject.increment(["FOO|"])
  end
  
  it "converts any values to strings for stat value, ignoring nil" do
    subject.expects(:send_to_socket)
      .with {|bin| bin.match /\.foo.1._.bar/ }

    subject.increment([:foo, 1, nil, "@", "BAR"])
  end

  it "times a given block" do
    subject.expects(:timing).with() {|b, val, timing| b == 'data.bin' && (1..11).include?(val) }.twice
    subject.time_for('data.bin')    { sleep 0.01 }
    subject.time_to_do('data.bin')  { sleep 0.01 }
  end

  it "registers a commit" do
    subject.expects(:timing).with(['event', 'commit', nil], anything).twice
    subject.commit
    subject.committed
  end

  it "registers a build" do
    subject.expects(:timing).with(['event', 'build', nil], anything).twice
    subject.build
    subject.built
  end

  it "registers a deploy" do
    subject.expects(:timing).with(['event', 'deploy', nil], anything).twice
    subject.deploy
    subject.deployed
  end

  it "ensures block is called on socket error" do
    UDPSocket.any_instance.stubs(:send).raises(SocketError)
    proc { subject.time_for('data.bin')   { sleep 0.01 } }.should_not raise_error
    proc { subject.time_to_do('data.bin') { sleep 0.01 } }.should_not raise_error
  end

  it "raises exception if natural exception from block" do
    proc { subject.time_for('data.bin') { raise ArgumentError, "testing" } }.should raise_error(ArgumentError)
  end

  it "only calls the block once on SocketError" do
    UDPSocket.any_instance.stubs(:send).raises(SocketError)
    i = 0
    p = proc {|n| (n + 1) }
    val = subject.time_for('data.bin') { i+= p.call(i) }
    val.should == 1
  end

  it "raises Timeout on slow lookup" do
    Fozzie.c.timeout = 0.01
    UDPSocket.any_instance.stubs(:send).with(any_parameters) { sleep 0.4 }
    subject.increment('data.bin').should eq false
  end

  describe "#increment_on" do

    it "registers success" do
      subject.expects(:increment).with(["event.increment", "success"], 1)
      subject.increment_on('event.increment', true).should == true
    end

    it "registers failure" do
      subject.expects(:increment).with(["event.increment", "fail"], 1)
      subject.increment_on('event.increment', false).should == false
    end

    it "simply questions the passed val with if" do
      a = mock()
      a.expects(:save).returns({})
      subject.expects(:increment).with(["event.increment", "success"], 1)
      subject.increment_on('event.increment', a.save).should == {}
    end

    it "registers fail on nil return" do
      a = mock()
      a.expects(:save).returns(nil)
      subject.expects(:increment).with(["event.increment", "fail"], 1)
      subject.increment_on('event.increment', a.save).should == nil
    end

    describe "performing actions" do

      it "registers success" do
        a = mock()
        a.expects(:save).returns(true)
        subject.expects(:increment).with(["event.increment", "success"], 1)
        subject.increment_on('event.increment', a.save).should == true
      end

      it "registers failure" do
        a = mock()
        a.expects(:save).returns(false)
        subject.expects(:increment).with(["event.increment", "fail"], 1)
        subject.increment_on('event.increment', a.save).should == false
      end

      it "registers positive even when nested" do
        a = mock()
        a.expects(:save).returns(true)
        subject.expects(:timing).with('event.run', any_parameters)
        subject.expects(:increment).with(["event.increment", "success"], 1)

        res = subject.time_to_do "event.run" do
          subject.increment_on('event.increment', a.save)
        end
        res.should == true
      end

      it "registers negative even when nested" do
        a = mock()
        a.expects(:save).returns(false)
        subject.expects(:timing).with('event.run', any_parameters)
        subject.expects(:increment).with(["event.increment", "fail"], 1)

        res = subject.time_to_do "event.run" do
          subject.increment_on('event.increment', a.save)
        end
        res.should == false
      end

      it "allows passing of arrays for stat key" do
        subject.expects(:timing).with(['event', 'commit'], any_parameters)
        subject.time_to_do %w{event commit} do; end
      end

    end

  end

  describe "#gauge" do
    it "registers a gauge measurement" do
      subject.expects(:send).with("mystat", 99, "g", 1)
      subject.gauge("mystat", 99)
    end
  end

end
