require 'spec_helper'
require 'action_controller'

describe Fozzie::Rails::Middleware do
  let(:routes)  { mock "routes" }

  subject do
    RailsApp = Class.new do
      def call(env); env end
    end unless defined?(RailsApp)
    Fozzie::Rails::Middleware.new RailsApp.new
  end

  before do
    Rails = rails unless defined?(Rails)
  end
  
  describe "#rails_version" do
    let(:version) { "10.9.8" }
    let(:rails)   { mock "rails" }

    before do
      ::Rails.stubs(:version).returns(version)
    end
    
    it "returns the major version from Rails.version" do
      subject.rails_version.should == 10
    end
  end
  
  describe "#routing_lookup" do
    context "when #rails_version == 3" do
      let(:app) { mock "app" }
      
      before do
        subject.stubs(:rails_version).returns(3)
      end

      it "returns Rails.application.routes" do
        Rails.expects(:application).returns(app)
        app.expects(:routes).returns(routes)
        subject.routing_lookup.should eq routes
      end
    end
    
    context "when #rails_version does not == 3" do
      before do
        if defined?(ActionController::Routing::Routes)
          
          @old_routes_const = ActionController::Routing::Routes
          ActionController::Routing.send(:remove_const, :Routes)
        end
        ActionController::Routing::Routes = routes
      end

      after do
        if @old_routes_const
          ActionController::Routing.send(:remove_const, :Routes)
          ActionController::Routing::Routes = @old_routes_const
        end
      end

      it "returns ActionController::Routing::Routes" do
        subject.routing_lookup.should eq routes
      end
    end
  end

  describe "#generate_key" do
    let(:env)  { mock "env" }
    let(:path) { mock "path" }
    let(:request_method) { mock "request_method" }
    
    it "gets the path_info and request method from env parameter" do
      env.expects(:[]).with("PATH_INFO")
      env.expects(:[]).with("REQUEST_METHOD")
      subject.generate_key(env)
    end

    context "when path_info is nil" do
      let(:env) { { "PATH_INFO" => nil } }
          
      it "does not lookup routing" do
        subject.expects(:routing_lookup).never
        subject.generate_key(env)
      end

      it "does not register any stats" do
        S.expects(:increment).never
      end

      it "returns nil" do
        subject.generate_key(env).should be_nil
      end
    end

    context "when path info is not nil" do
      let(:env) { { "PATH_INFO" => path, "REQUEST_METHOD" => request_method } }
      
      before do
        subject.stubs(:routing_lookup).returns(routes)
        routes.stubs(:recognize_path).returns({ :controller => "controller",
                                                :action     => "action" })
      end
      
      it "looks up controller and action for the path and request method" do
        subject.expects(:routing_lookup).returns(routes)
        routes.expects(:recognize_path).with(path, :method => request_method)
        subject.generate_key(env)
      end

      it "returns a bucket generated from the controller, action, and 'render'" do
        subject.generate_key(env).should eq "controller.action.render"
      end
    end
  end

  
  describe "subject" do
    it "returns env on call for testing" do
      subject.call({}).should == {}
    end
  end

end
