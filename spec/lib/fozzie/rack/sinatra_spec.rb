require 'fozzie/rack/middleware'
require 'sinatra/base'
require 'rack/test'

describe "Sinatra Server with Middleware" do
  include Rack::Test::Methods

  def app
    Sinatra.new do
      set :environment, :test
      use Fozzie::Rack::Middleware
      get('/') { "echo" }
      get('/somewhere/nice') { "echo" }
    end
  end

  it "sends stats request on root" do
    S.should_receive(:timing).with('index.render', anything, anything, anything)
    get '/'
    last_response.should be_ok
    last_response.body.should == 'echo'
  end

  it "sends stats request on nested path" do
    S.should_receive(:timing).with('somewhere.nice.render', anything, anything, anything)

    get '/somewhere/nice'
    last_response.should be_ok
    last_response.body.should == 'echo'
  end
end
