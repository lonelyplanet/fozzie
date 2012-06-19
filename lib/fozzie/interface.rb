require 'singleton'
require 'fozzie/socket'

module Fozzie
  class Interface
    include Fozzie::Socket, Singleton

    # Increments the given stat by one, with an optional sample rate
    #
    # `Stats.increment 'wat'`
    def increment(stat, sample_rate=1)
      count(stat, 1, sample_rate)
    end

    # Decrements the given stat by one, with an optional sample rate
    #
    # `Stats.decrement 'wat'`
    def decrement(stat, sample_rate=1)
      count(stat, -1, sample_rate)
    end

    # Registers a count for the given stat, with an optional sample rate
    #
    # `Stats.count 'wat', 500`
    def count(stat, count, sample_rate=1)
      send(stat, count, 'c', sample_rate)
    end

    # Registers a timing (in ms) for the given stat, with an optional sample rate
    #
    # `Stats.timing 'wat', 500`
    def timing(stat, ms, sample_rate=1)
      send(stat, ms, 'ms', sample_rate)
    end

    # Registers the time taken to complete a given block (in ms), with an optional sample rate
    #
    # `Stats.time 'wat' { # Do something... }`
    def time(stat, sample_rate=1)
      start  = Time.now
      result = yield
      timing(stat, ((Time.now - start) * 1000).round, sample_rate)
      result
    end

    # Registers the time taken to complete a given block (in ms), with an optional sample rate
    #
    # `Stats.time_to_do 'wat' { # Do something, again... }`
    def time_to_do(stat, sample_rate=1, &block)
      time_for(stat, sample_rate, &block)
    end

    # Registers the time taken to complete a given block (in ms), with an optional sample rate
    #
    # `Stats.time_for 'wat' { # Do something, grrr... }`
    def time_for(stat, sample_rate=1, &block)
      time(stat, sample_rate, &block)
    end

    # Registers a commit
    #
    # `Stats.commit`
    def commit
      event :commit
    end

    # Registers a commit
    #
    # `Stats.commit`
    def committed
      commit
    end

    # Registers that the app has been built
    #
    # `Stats.built`
    def built
      event :build
    end

    # Registers a build for the app
    #
    # `Stats.build`
    def build
      built
    end

    # Registers a deployed status for the given app
    #
    # `Stats.deployed 'watapp'`
    def deployed(app = nil)
      event :deploy, app
    end

    # Registers a deployment for the given app
    #
    # `Stats.deploy 'watapp'`
    def deploy(app = nil)
      deployed(app)
    end

    # Registers an increment on the result of the given boolean
    #
    # `Stats.increment_on 'wat', wat.random?`
    def increment_on(stat, perf, sample_rate=1)
      key = [stat, (perf ? "success" : "fail")]
      increment(key, sample_rate)
      perf
    end

    # Register an event of any type
    #
    # `Stats.event 'wat', 'app'`
    def event(type, app = nil)
      timing ["event", type.to_s, app], Time.now.usec
    end

    # Register an arbitrary value
    def gauge(stat, value)
      send(stat, value, "g", sample_rate = 1)
    end
  end
end
