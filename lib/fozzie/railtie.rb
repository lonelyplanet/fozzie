require 'fozzie/rails/engine'
require 'fozzie/configuration'

class FozzieRailtie < Rails::Railtie
  @fozzie_railtie_block = Proc.new do |app|
    if Fozzie::config.enable_rails_middleware
      # Load up the middleware
      app.middleware.use Fozzie::Rails::Middleware

      # Add the Mill route
      app.routes.prepend do
        mount Fozzie::Rails::Engine => '/mill'
      end
    end
  end

  class << self
    attr_reader :fozzie_railtie_block
  end

  initializer "fozzie_railtie.configure_rails_initialization", &@fozzie_railtie_block
end
