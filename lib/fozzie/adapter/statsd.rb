require 'socket'
require 'resolv'

module Fozzie
  module Adapter
    class Statsd

      RESERVED_CHARS_REGEX       = /[\:\|\@\s]/
      RESERVED_CHARS_REPLACEMENT = '_'
      DELIMETER                  = '.'
      SAFE_SEPARATOR             = '-'
      TYPES                      = { :gauge => 'g', :count => 'c', :timing => 'ms' }
      BULK_DELIMETER             = "\n"

      # Send the statistic to the server
      #
      # Creates the Statsd key from the given values, and sends to socket (depending on sample rate)
      def register(*stats)
        metrics = stats.flatten.map do |stat|
          next if sampled?(stat[:sample_rate])

          bucket = format_bucket(stat[:bucket])
          value  = format_value(stat[:value], stat[:type], stat[:sample_rate])

          [bucket, value].join(':')
        end.compact.join(BULK_DELIMETER)

        send_to_socket(metrics)
      end

      def format_bucket(stat)
        bucket = [stat].flatten.compact.collect(&:to_s).join(DELIMETER).downcase
        bucket = bucket.gsub('::', DELIMETER).gsub(RESERVED_CHARS_REGEX, RESERVED_CHARS_REPLACEMENT)
        bucket = [Fozzie.c.data_prefix, bucket].compact.join(DELIMETER)

        bucket
      end

      def format_value(val, type, sample_rate)
        converted_type = TYPES[type.to_sym]
        converted_type ||= TYPES[:gauge]

        value = [val, converted_type].join('|')
        value << '@%s' % sample_rate.to_s if sample_rate < 1

        value
      end

      # If the statistic is sampled, generate a condition to check if it's good to send
      def sampled(sample_rate)
        yield unless sampled?(sample_rate)
      end

      def sampled?(sample_rate)
        sample_rate < 1 and rand > sample_rate
      end

      # Send data to the server via the socket
      def send_to_socket(message)
        Fozzie.logger.debug {"Statsd: #{message}"} if Fozzie.logger
        Timeout.timeout(Fozzie.c.timeout) {
          res = socket.send(message, 0, host_ip, host_port)
          Fozzie.logger.debug {"Statsd sent: #{res}"} if Fozzie.logger
          (res.to_i == message.length)
        }
      rescue => exc
        Fozzie.logger.debug {"Statsd Failure: #{exc.message}\n#{exc.backtrace}"} if Fozzie.logger
        false
      end

      # The Socket we want to use to send data
      def socket
        @socket ||= ::UDPSocket.new
      end

      def host_ip
        @host_ip ||= Resolv.getaddress(Fozzie.c.host)
      end

      def host_port
        @host_port ||= Fozzie.c.port
      end

      def delimeter
        DELIMETER
      end

      def safe_separator
        SAFE_SEPARATOR
      end
    end

  end
end
