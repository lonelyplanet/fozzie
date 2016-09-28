require 'fozzie/adapter/statsd'

module Fozzie
  module Adapter
    class Datadog < Statsd

      # stats is a collection of hashes in the following format:
      # { :bucket => stat, :value => value, :type => type, :sample_rate => sample_rate, tags => ["serviceid:fozzie","country:au"] }
      def register(*stats)
        metrics = stats.flatten.map do |stat|
          next if sampled?(stat[:sample_rate])

          bucket = format_bucket(stat[:bucket])
          value  = format_value(stat[:value], stat[:type], stat[:sample_rate])
          tags   = (stat[:tags] || []).map {|tag| tag.gsub(/[,\|]/, RESERVED_CHARS_REPLACEMENT)}

          result = "#{bucket}:#{value}" 
          result << "|##{tags.join(',')}" if tags.any? 
          result
        end.compact.join(BULK_DELIMETER)

        send_to_socket(metrics)
      end
    end
  end
end
