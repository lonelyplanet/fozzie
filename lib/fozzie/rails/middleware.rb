require 'fozzie/rack/middleware'

module Fozzie
  module Rails

    # Time and record each request through a given Rails app
    # This middlewware times server processing for a resource, not view render.
    class Middleware < Fozzie::Rack::Middleware

      # Generates the statistics key for the current path
      def generate_key(env)
        path_str       = env['PATH_INFO']
        request_method = env['REQUEST_METHOD']

        return nil unless path_str

        begin
          routing = routing_lookup
          path    = routing.recognize_path(path_str, :method => request_method)
          stat    = [path[:controller], path[:action], "render"].join('.')
          stat
        rescue => exc
          S.increment "routing.error"
          nil
        end
      end

      def routing_lookup
        (rails_version == 3 ? ::Rails.application.routes : ::ActionController::Routing::Routes)
      end

      def rails_version
        ::Rails.version.to_i
      end

    end

  end
end
