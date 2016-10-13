%w{statsd datadog}.each {|r| require "fozzie/adapter/#{r}" }
