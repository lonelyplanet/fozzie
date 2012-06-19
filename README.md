# Fozzie [![travis-ci](https://secure.travis-ci.org/lonelyplanet/fozzie.png)](https://secure.travis-ci.org/lonelyplanet/fozzie)

Ruby gem for registering statistics to a [Statsd](https://github.com/etsy/statsd) server in various ways.

## Requirements

* A Statsd server
* Ruby 1.9

## Basic Usage

Send through statistics depending on the type you want to provide:

### Increment counter

    Stats.increment 'wat' # increments the value in a Statsd bucket called 'some.prefix.wat' -
                          # the exact bucket name depends on the bucket name prefix (see below)
                           
### Decrement counter

    Stats.decrement 'wat'

### Decrement counter - provide a value as integer

    Stats.count 'wat', 5

### Basic timing - provide a value in milliseconds

    Stats.timing 'wat', 500

### Timings - provide a block to time against (inline and do syntax supported)

    Stats.time 'wat' { sleep 5 }

    Stats.time_to_do 'wat' do
      sleep 5
    end

    Stats.time_for 'wat' { sleep 5 }

### Gauges - register arbitrary values

    Stats.gauge 'wat', 99

### Events - register different events


#### Commits

    Stats.commit

    Stats.committed

#### Builds

    Stats.built

    Stats.build

#### Deployments

    Stats.deployed

  With a custom app:

    Stats.deployed 'watapp'

    Stats.deploy

  With a custom app:

    Stats.deploy 'watapp'

#### Custom

    Stats.event 'pull'

  With a custom app:

    Stats.event 'pull', 'watapp'

### Boolean result - pass a value to be true or false, and increment on true

    Stats.increment_on 'wat', duck.valid?

## Sampling

Each of the above methods accepts a sample rate as the last argument (before any applicable blocks), e.g:

    Stats.increment 'wat', 10

    Stats.decrement 'wat', 10

    Stats.count 'wat', 5, 10

## Namespaces

Fozzie supports the following namespaces as default

    Stats.increment 'wat'
    S.increment 'wat'
    Statistics.increment 'wat'
    Warehouse.increment 'wat'

You can customise this via the YAML configuration (see instructions below)

## Configuration

Fozzie is configured via a YAML or by setting a block against the Fozzie namespace.

### YAML

Create a `fozzie.yml` within a `config` folder on the root of your app, which contains your settings for each env. Simple, verbose example below.

    development:
      appname: wat
      host: '127.0.0.1'
      port: 8125
      namespaces: %w{Foo Bar Wat}
    test:
      appname: wat
      host: 'localhost'
      port: 8125
      namespaces: %w{Foo Bar Wat}
    production:
      appname: wat
      host: 'stats.wat.com'
      port: 8125
      namespaces: %w{Foo Bar Wat}

### Configure block

    Fozzie.configure do |config|
      config.appname = "wat"
      config.host    = "127.0.0.1"
      config.port    = 8125
    end

## Middleware

To time and register the controller actions within your Rails application, Fozzie provides some middleware.

### Rack

    require 'rack'
    require 'fozzie'

    app = Rack::Builder.new {
      use Fozzie::Rack::Middleware
      lambda { |env| [200, {'Content-Type' => 'text/plain'}, 'OK'] }
    }

### Rails

Based on the Rack middleware above, but is more involved in its construction of the bucket value.

Fozzie::Rails::Middleware will automatically be invoked on Rails initialization.

## Bucket name prefixes

Fozzie automatically constructs bucket name prefixes from app name,
hostname, and environment. For example:

    Stats.increment 'wat'

increments the bucket named

    app-name.your-computer-name.development.wat

When working on your development machine. This allows multiple
application instances, in different environments, to be distinguished
easily and collated in Graphite quickly.

The app name can be configured via the YAML configuration.

## Low level behaviour

The current implementation of Fozzie wraps the sending of the statistic in a timeout and rescue block, which prevent long host lookups (i.e. if your stats server disappears) and minimises impact on your code or application if something is erroring at a low level.

Fozzie will try to log these errors, but only if a logger has been applied (which by default it does not). Examples:
  
    require 'logger'
    Fozzie.logger = Logger.new(STDOUT)

    require 'logger'
    Fozzie.logger = Logger.new 'log/fozzie.log'

This may change, depending on feedback and more production experience.

## Rails User Interface Performance Measuring

If you also require UI metrics, you can also include the Mill script in the bottom of any page you would like to measure (see `resources/mill.js` and `resources/mill.min.js`) and you start receiving measurements on page performance.

## Credits

Currently supported and maintained by [Marc Watts](marc.watts@lonelyplanet.co.uk) @ Lonely Planet Online.

Big thanks and Credits:

* [Mark Barger](mark.barger@lonelyplanet.co.uk) for support in trying to make this Gem useful.

* [Dave Nolan](https://github.com/textgoeshere)

* [Etsy](http://codeascraft.etsy.com/) whose [Statsd](https://github.com/etsy/statsd) product has enabled us to come such a long way in a very short period of time. We love Etsy.

* [reinh](https://github.com/reinh/statsd) for his [statsd](https://github.com/reinh/statsd) Gem.

## Comments and Feedback

Please [contact](marc.watts@lonelyplanet.co.uk) me on anything... improvements will be needed and are welcomed greatly.
