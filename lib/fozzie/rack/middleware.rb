require 'fozzie'

module Fozzie
  module Rack

    # Time and record each request through a given Rack app
    # This middleware times server processing for a resource, not view render.
    class Middleware

      attr_reader :app

      def initialize(app)
        @app = app
      end

      def call(env)
        k = generate_key(env)
        if k.nil?
          self.call_without_timer(env)
        else
          self.call_with_timer(k, env)
        end
      end

      def call_without_timer(env)
        @app.call(env)
      end

      def call_with_timer(key, env)
        S.time_to_do key do
          @app.call(env)
        end
      end

      def generate_key(env)
        s = env['PATH_INFO']
        return nil if s.nil?
        s = (s == '/' ? 'index' : s.gsub(/.(\/)./) {|m| m.gsub('/', '.') }.gsub(/\//, '').strip)
        (s.nil? || s.empty? ? nil : "#{s}.render")
      end

    end
  end
end
