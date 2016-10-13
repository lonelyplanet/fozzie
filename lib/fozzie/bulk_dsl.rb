module Fozzie
  class BulkDsl
    include Fozzie::Interface

    def initialize(&block)
      @metrics = []
      block.arity < 1 ? instance_eval(&block) : block.call(self) if block_given?
      send_bulk
    end

    private

    # Cache the requested metrics for bulk sending
    def send(stat, value, type, sample_rate = 1, extra = {})
     val = extra.merge({ :bucket => stat, :value => value, :type => type, :sample_rate => sample_rate })

     @metrics.push(val)
    end

    def send_bulk
      return if @metrics.empty?

      adapter.register(@metrics)
    end

  end
end
