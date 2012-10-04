require 'spec_helper'
require 'rails/engine'
require 'fozzie'
require 'fozzie/railtie'

describe "FozzieRailtie" do

  let(:app) { double("app") }
  let(:middleware) { double("middleware") }
  let(:routes) { double("routes") }

  subject { FozzieRailtie.fozzie_railtie_block.call(app) }

  context "when rails middleware is enabled" do

    before do
      app.should_receive(:middleware).and_return(middleware)
      middleware.should_receive(:use)
      app.should_receive(:routes).and_return(routes)
      routes.should_receive(:prepend)
      require 'fozzie/railtie'
    end

    specify { expect{subject}.not_to raise_error }
  end

  context "when rails middleware is not enabled" do
    before do
      Fozzie::config.enable_rails_middleware=false
    end

    specify { expect{subject}.not_to raise_error }
  end
end
