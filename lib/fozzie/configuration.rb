require 'active_support/core_ext/hash/indifferent_access'
require 'yaml'
require 'sys/uname'
require 'timeout'

module Fozzie

  # Fozzie configuration allows assignment of global properties
  # that will be used within the Fozzie codebase.
  class Configuration
    include Sys

    attr_accessor :env, :config_path, :host, :port, :appname, :namespaces, :timeout, :monitor_classes, :sniff_envs

    def initialize(args = {})
      merge_and_assign_config(args)
      self.origin_name
    end

    # Returns the prefix for any stat requested to be registered
    def data_prefix
      s = [appname, origin_name, env].collect do |s|
        s.empty? ? nil : s.gsub('.', '-')
      end.compact.join('.').strip
      (s.empty? ? nil : s)
    end

    # Returns the origin name of the current machine to register the stat against
    def origin_name
      @origin_name ||= Uname.uname.nodename
    end

    def sniff?
      self.sniff_envs.collect(&:to_sym).include?(self.env.to_sym)
    end

    private

    # Handle the merging of the given configuaration, and the default config.
    def merge_and_assign_config(args = {})
      arg = self.class.default_configuration.merge(args)
      arg.merge!(config_from_yaml(arg))
      arg.each {|a,v| self.send("#{a}=", v) if self.respond_to?(a.to_sym) }
      arg
    end

    # Default configuration settings
    def self.default_configuration
      {
        :host            => '127.0.0.1',
        :port            => 8125,
        :config_path     => '',
        :env             => (ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'),
        :appname         => '',
        :namespaces      => %w{Stats S Statistics Warehouse},
        :timeout         => 0.5,
        :monitor_classes => [],
        :sniff_envs      => [:development, :staging, :production]
      }.with_indifferent_access
    end

    # Loads the configuration from YAML, if possible
    def config_from_yaml(args)
      fp = full_config_path(args[:config_path])
      return {} unless File.exists?(fp)
      YAML.load(File.open(fp))[args[:env]] || {}
    end

    # Returns the absolute file path for the Fozzie configuration, relative to the given path
    def full_config_path(path)
      File.expand_path('config/fozzie.yml', path)
    end

  end

end