# Fozzie is an implementation of the Statsd statistics gathering tool,
# designed to make gathering stastistics from applications easy, fast, and effective.
#
# Configuration can be applied through a block and/or configuration file ('config/fozzie.yml')
#
# Fozzie provides automatic namespacing for the current environment, and host.
#
# Rack and Rails middleware is avaliable to gather statistics on the processing time of Controller actions.
#

module Fozzie

  require 'core_ext/module/monitor'
  require 'core_ext/module/alias_method_chain'
  require 'core_ext/string/snakecase'
  require 'core_ext/hash/symbolize_keys'

  require 'fozzie/adapter'

  require "fozzie/exception"
  require 'fozzie/configuration'
  require "fozzie/dsl"
  require "fozzie/bulk_dsl"
  require "fozzie/version"

  class << self

    # Shortcut for `Fozzie.config`
    def c
      config
    end

    # Returns the current configuration. Creates configuration on first-time request
    def config
      @config ||= Configuration.new
    end

    # Allows the setting on valudes against the configuration
    #
    # `Fozzie.configure {|config| config.wat = :random }`
    def configure
      yield c if block_given?
    end

    # Set a logger
    #
    #
    # `Fozzie.logger = Logger.new(STDOUT)`
    def logger=(logger)
      @logger = logger
    end

    # Accessor for logger
    #
    # `Fozzie.logger.warn 'foo'`
    def logger
      @logger
    end

  end

  # Loads each namespace for registering statistics
  self.c.namespaces.each do |klas|
    Kernel.const_set(klas, Dsl.instance) unless const_defined?(klas)
  end

end
