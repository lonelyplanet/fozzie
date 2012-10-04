# Fozzie [![travis-ci](https://secure.travis-ci.org/lonelyplanet/fozzie.png)](https://secure.travis-ci.org/lonelyplanet/fozzie)

Ruby gem for registering statistics to a [Statsd](https://github.com/etsy/statsd) server in various ways.

## Requirements

* A Statsd server
* Ruby 1.9

## Basic Usage

Send through statistics depending on the type you want to provide:

### Increment counter
``` ruby
Stats.increment 'wat' # increments the value in a Statsd bucket called 'some.prefix.wat' -
                      # the exact bucket name depends on the bucket name prefix (see below)
```
### Decrement counter
``` ruby
Stats.decrement 'wat'
```
### Decrement counter - provide a value as integer
``` ruby
Stats.count 'wat', 5
```
### Basic timing - provide a value in milliseconds
``` ruby
Stats.timing 'wat', 500
```
### Timings - provide a block to time against (inline and do syntax supported)
``` ruby
Stats.time 'wat' { sleep 5 }

Stats.time_to_do 'wat' do
  sleep 5
end

Stats.time_for 'wat' { sleep 5 }
```
### Gauges - register arbitrary values
``` ruby
Stats.gauge 'wat', 99
```
### Events - register different events


#### Commits
``` ruby
Stats.commit

Stats.committed
```
#### Builds
``` ruby
Stats.built

Stats.build
```
#### Deployments
``` ruby
Stats.deployed
```

  With a custom app:
``` ruby
Stats.deployed 'watapp'

Stats.deploy
```

  With a custom app:
``` ruby
Stats.deploy 'watapp'
```

#### Custom
``` ruby
Stats.event 'pull'
```
With a custom app:

``` ruby
Stats.event 'pull', 'watapp'
```
### Boolean result - pass a value to be true or false, and increment on true
``` ruby
Stats.increment_on 'wat', duck.valid?
```
## Sampling

Each of the above methods accepts a sample rate as the last argument (before any applicable blocks), e.g:

``` ruby
Stats.increment 'wat', 10

Stats.decrement 'wat', 10

Stats.count 'wat', 5, 10
```
## Monitor

You can monitor methods with the following:
``` ruby
class FooBar

  _monitor
  def zar
    # my code here...
  end

  _monitor("my.awesome.bucket.name")
  def quux
    # something
  end

end
```
This will register the processing time for this method, everytime it is called, under the Graphite bucket `foo_bar.zar`.

This will work on both Class and Instance methods.

## Bulk

You can send a bulk of metrics using the `bulk` method:
``` ruby
Stats.bulk do
  increment 'wat'
  decrement 'wot'
  gauge 'foo', rand
  time_to_do 'wat_timer' { sleep 4 }
end
```

This will send all the given metrics in a single packet to the statistics server.

## Namespaces

Fozzie supports the following namespaces as default

``` ruby
Stats.increment 'wat'
S.increment 'wat'
Statistics.increment 'wat'
Warehouse.increment 'wat'
```

You can customise this via the YAML configuration (see instructions below)

## Configuration

Fozzie is configured via a YAML or by setting a block against the Fozzie namespace.

### YAML

Create a `fozzie.yml` within a `config` folder on the root of your app, which contains your settings for each env. Simple, verbose example below.

``` yaml
development:
  appname: wat
  host: '127.0.0.1'
  port: 8125
  namespaces: %w{Foo Bar Wat}
  prefix: %{foo bar car}
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
```

### Configure block

``` ruby
Fozzie.configure do |config|
  config.appname = "wat"
  config.host    = "127.0.0.1"
  config.port    = 8125
  config.prefix  = []
end
```
### Prefixes

You can inject or set the prefix value for your application.

``` ruby
Fozzie.configure do |config|
  config.prefix = ['foo', 'wat', 'bar']
end
```

``` ruby
Fozzie.configure do |config|
  config.prefix << 'dynamic-value'
end
```

Prefixes are cached on first use, therefore any changes to the Fozzie configure prefix after first metric is sent in your application will be ignored.

## Middleware

To time and register the controller actions within your Rails application, Fozzie provides some middleware.

### Rack

``` ruby
require 'rack'
require 'fozzie'

app = Rack::Builder.new {
  use Fozzie::Rack::Middleware
  lambda { |env| [200, {'Content-Type' => 'text/plain'}, 'OK'] }
}
```

### Rails

Based on the Rack middleware above, but is more involved in its construction of the bucket value.

Fozzie::Rails::Middleware will automatically be invoked on Rails initialization. It can be disabled with the following
configuration setting:

``` yaml
    enable_rails_middleware: false
```

## Bucket name prefixes

Fozzie automatically constructs bucket name prefixes from app name,
hostname, and environment. For example:

``` ruby
Stats.increment 'wat'
```
increments the bucket named
``` text
app-name.your-computer-name.development.wat
```

When working on your development machine. This allows multiple
application instances, in different environments, to be distinguished
easily and collated in Graphite quickly.

The app name can be configured via the YAML configuration.

## Low level behaviour

The current implementation of Fozzie wraps the sending of the statistic in a timeout and rescue block, which prevent long host lookups (i.e. if your stats server disappears) and minimises impact on your code or application if something is erroring at a low level.

Fozzie will try to log these errors, but only if a logger has been applied (which by default it does not). Examples:

``` ruby
require 'logger'
Fozzie.logger = Logger.new(STDOUT)
```

``` ruby
require 'logger'
Fozzie.logger = Logger.new 'log/fozzie.log'
```

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
