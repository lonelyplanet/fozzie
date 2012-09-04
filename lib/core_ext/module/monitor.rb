require 'fozzie/sniff'

class Module

  def _monitor(bucket_name = nil)
    return unless Fozzie.c.sniff?
    self.class_eval { include Fozzie::Sniff }
    @_monitor_flag = true
    @_bucket_name  = bucket_name
  end

end
