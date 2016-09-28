shared_examples "interface" do
  it "#increment" do
    subject.should_receive(:send).with('wat', 1, :count, 1, {})
    subject.increment 'wat'
  end

  it "#decrement" do
    subject.should_receive(:send).with('wat', -1, :count, 1, {})
    subject.decrement 'wat'
  end

  it "#count" do
    subject.should_receive(:send).with('wat', 5, :count, 1, {})
    subject.count 'wat', 5
  end

  it "#timing" do
    subject.should_receive(:send).with('wat', 500, :timing, 1, {})
    subject.timing 'wat', 500
  end

  it "times a given block" do
    subject.should_receive(:timing).with(/data.bin/, kind_of(Numeric), 1, {}).exactly(3).times

    subject.time_for('data.bin')   { true }
    subject.time_to_do('data.bin') { true }
    subject.time('data.bin')       { true }
  end

  describe "event" do
    it "for a commit" do
      subject.should_receive(:gauge).with(['event', 'commit', nil], anything, 1, {}).twice
      subject.commit
      subject.committed
    end

    it "for a build" do
      subject.should_receive(:gauge).with(['event', 'build', nil], anything, 1, {}).twice
      subject.build
      subject.built
    end

    it "for a deploy" do
      subject.should_receive(:gauge).with(['event', 'deploy', nil], anything, 1, {}).twice
      subject.deploy
      subject.deployed
    end

    it "for anything" do
      subject.should_receive(:send).with(['event', 'foo', nil], anything, :gauge, 1, {})
      subject.event 'foo'
    end

    it "accepts an app name" do
      subject.should_receive(:send).with(['event', 'foo', 'fozzie'], anything, :gauge, 1, {})
      subject.event 'foo', 'fozzie'
    end
  end

  describe "#increment_on" do
    it "registers success" do
      subject.should_receive(:increment).with(["event.increment", "success"], 1, {})
      subject.increment_on('event.increment', true).should == true
    end

    it "registers failure" do
      subject.should_receive(:increment).with(["event.increment", "fail"], 1, {})
      subject.increment_on('event.increment', false).should == false
    end

    it "simply questions the passed val with if" do
      a = double
      a.should_receive(:save).and_return({})
      subject.should_receive(:increment).with(["event.increment", "success"], 1, {})
      subject.increment_on('event.increment', a.save).should == {}
    end

    it "registers fail on nil return" do
      a = double
      a.should_receive(:save).and_return(nil)
      subject.should_receive(:increment).with(["event.increment", "fail"], 1, {})
      subject.increment_on('event.increment', a.save).should == nil
    end

    describe "performing actions" do
      it "registers success" do
        a = double
        a.should_receive(:save).and_return(true)
        subject.should_receive(:increment).with(["event.increment", "success"], 1, {})
        subject.increment_on('event.increment', a.save).should == true
      end

      it "registers failure" do
        a = double
        a.should_receive(:save).and_return(false)
        subject.should_receive(:increment).with(["event.increment", "fail"], 1, {})
        subject.increment_on('event.increment', a.save).should == false
      end

      it "registers positive even when nested" do
        a = double
        a.should_receive(:save).and_return(true)
        subject.should_receive(:timing).with('event.run', anything, anything, {})
        subject.should_receive(:increment).with(["event.increment", "success"], 1, {})

        res = subject.time_to_do "event.run" do
          subject.increment_on('event.increment', a.save)
        end
        res.should == true
      end

      it "registers negative even when nested" do
        a = double
        a.should_receive(:save).and_return(false)
        subject.should_receive(:timing).with('event.run', anything, anything, {})
        subject.should_receive(:increment).with(["event.increment", "fail"], 1, {})

        res = subject.time_to_do "event.run" do
          subject.increment_on('event.increment', a.save)
        end
        res.should == false
      end
    end
  end

  describe "#bulk" do
    it "registers statistics in a single call" do
      Fozzie.c.adapter.should_receive(:register).once

      subject.bulk do
        increment :foo
        decrement :bar
      end
    end
  end

  it "registers a gauge measurement" do
    subject.should_receive(:send).with("mystat", 99, :gauge, 1, {})
    subject.gauge("mystat", 99)
  end

  it "raises exception if natural exception from block" do
    proc { subject.time_to_do('data.bin', 1, :gauge, 1) { raise ArgumentError, "testing" } }.should raise_error(ArgumentError)
  end

  it "only calls the block once on error" do
    Fozzie.c.adapter.stub(:send) { raise SocketError }
    i = 0
    p = proc {|n| (n + 1) }
    val = subject.time_to_do('data.bin') { i+= p.call(i) }

    val.should == 1
  end
end
