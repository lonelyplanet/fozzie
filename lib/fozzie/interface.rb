require 'fozzie/adapter/statsd'
require 'fozzie/adapter/datadog'

module Fozzie
  module Interface

    # Increments the given stat by one, with an optional sample rate
    #
    # `Stats.increment 'wat'`
    def increment(stat, sample_rate=1, extra = {})
      count(stat, 1, sample_rate, extra)
    end

    # Decrements the given stat by one, with an optional sample rate
    #
    # `Stats.decrement 'wat'`
    def decrement(stat, sample_rate=1, extra = {})
      count(stat, -1, sample_rate, extra)
    end

    # Registers a count for the given stat, with an optional sample rate
    #
    # `Stats.count 'wat', 500`
    def count(stat, count, sample_rate=1, extra = {})
      send(stat, count, :count, sample_rate, extra)
    end

    # Registers a timing (in ms) for the given stat, with an optional sample rate
    #
    # `Stats.timing 'wat', 500`
    def timing(stat, ms, sample_rate=1, extra = {})
      send(stat, ms, :timing, sample_rate, extra)
    end

    # Registers the time taken to complete a given block (in ms), with an optional sample rate
    #
    # `Stats.time 'wat' { # Do something... }`
    def time(stat, sample_rate=1, extra = {})
      start  = Time.now
      result = yield
      timing(stat, ((Time.now - start) * 1000).round, sample_rate, extra)
      result
    end

    # Registers the time taken to complete a given block (in ms), with an optional sample rate
    #
    # `Stats.time_to_do 'wat' { # Do something, again... }`
    def time_to_do(stat, sample_rate=1, extra = {}, &block)
      time(stat, sample_rate, extra, &block)
    end

    # Registers the time taken to complete a given block (in ms), with an optional sample rate
    #
    # `Stats.time_for 'wat' { # Do something, grrr... }`
    def time_for(stat, sample_rate=1, extra = {}, &block)
      time(stat, sample_rate, extra, &block)
    end

    # Registers a commit
    #
    # `Stats.commit`
    def commit(extra = {})
      event(:commit, nil, extra)
    end

    # Registers a commit
    #
    # `Stats.commit`
    def committed(extra = {})
      commit(extra)
    end

    # Registers that the app has been built
    #
    # `Stats.built`
    def built(extra = {})
      event(:build, nil, extra)
    end

    # Registers a build for the app
    #
    # `Stats.build`
    def build(extra = {})
      built(extra)
    end

    # Registers a deployed status for the given app
    #
    # `Stats.deployed 'watapp'`
    def deployed(app = nil, extra = {})
      event(:deploy, app, extra)
    end

    # Registers a deployment for the given app
    #
    # `Stats.deploy 'watapp'`
    def deploy(app = nil, extra = {})
      deployed(app, extra)
    end

    # Register an event of any type
    #
    # `Stats.event 'wat', 'app'`
    def event(type, app = nil, extra = {})
      gauge(["event", type.to_s, app], Time.now.usec, 1, extra)
    end

    # Registers an increment on the result of the given boolean
    #
    # `Stats.increment_on 'wat', wat.random?`
    def increment_on(stat, perf, sample_rate=1, extra = {})
      key = [stat, (perf ? "success" : "fail")]
      increment(key, sample_rate, extra)
      perf
    end

    # Register an arbitrary value
    #
    # `Stats.gauge 'wat', 'app'`
    def gauge(stat, value, sample_rate = 1, extra = {})
      send(stat, value, :gauge, sample_rate, extra)
    end

    # Register multiple statistics in a single call
    #
    # `Stats.bulk do
    #    increment 'wat'
    #    decrement 'wot'
    # end`
    def bulk(&block)
      Fozzie::BulkDsl.new(&block)
    end

    private

    def adapter
      Fozzie.c.adapter
    end
  end
end
