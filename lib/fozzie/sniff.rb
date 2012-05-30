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

      def _monitor
        @_monitor_flag = true
      end

      def _monitor_meth(target, &blk)
        return if @_monitor_flag.nil? || !@_monitor_flag

        @_monitor_flag, feature, bin = false, :monitor, [self.name.snakecase, target.to_s.snakecase]
        aliased_target, punctuation  = target.to_s.sub(/([?!=])$/, ''), $1

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
