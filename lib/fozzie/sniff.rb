require 'core_ext/module/monitor'
require 'facets/module/alias_method_chain' unless Module.methods.include?(:alias_method_chain)
require 'facets/string/snakecase'

module Fozzie
  module Sniff

    def self.included(klass)
      return if klass.include?(ClassMethods)

      klass.class_eval { extend ClassMethods }
    end

    module ClassMethods

      def _monitor(bucket_name = nil)
        @_monitor_flag = true
        @_bucket_name  = bucket_name
      end

      def _monitor_meth(target, &blk)
        return if @_monitor_flag.nil? || !@_monitor_flag

        @_monitor_flag = false
        bin            = @_bucket_name || [self.name.snakecase, target.to_s.snakecase]
        feature        = :monitor
        aliased_target = target.to_s.sub(/([?!=])$/, '')
        punctuation    = $1

        with    = "#{aliased_target}_with_#{feature}#{punctuation}"
        without = "#{aliased_target}_without_#{feature}#{punctuation}"

        blk.call(with, without, feature, bin)
      end

      def method_added(target)
        _monitor_meth(target) do |with, without, feature, bin|
          define_method(with) do |*args, &blk|
            S.time_for(bin) do
              args.empty? ? self.send(without, &blk) : self.send(without, *args, &blk)
            end
          end
          self.alias_method_chain(target, feature)
        end
      end

      def singleton_method_added(target)
        _monitor_meth(target) do |with, without, feature, bin|
          define_singleton_method(with) do |*args, &blk|
            S.time_for(bin) do
              args.empty? ? send(without, &blk) : send(without, *args, &blk)
            end
          end
          self.singleton_class.class_eval { alias_method_chain target, feature }
        end
      end

    end

  end
end
