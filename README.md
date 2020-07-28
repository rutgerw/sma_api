# SmaApi

This gem provides an API for the web interface of SMA inverters.

The gem is in early development and should not be considered stable. Everything might change.

## Supported inverters

This gem has been developed using a SMA Sunny Boy 3.0 (SB3.0-1AV-41 902).
Firmware version is 3.10.18.R

It will probably work with other SMA products that have a recent firmware. But
it has not been tested.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sma_api', git: 'https://github.com/rutgerw/sma_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sma_api

## Usage

The web interface of the inverter does not allow an unlimited number of sessions.
There seems to be a limit of 4 sessions. Another attempt to login will result into
an error message from the web interface, which is turned into a `SmaApi::Error`
that has the `Creating session failed` message. The software in the inverter will
free up a session after a 5 minute inactivity.

There are different ways of handling the session:
- Create the `SmaApi::Client` instance just once and use it multiple times
- Store the session id in a cache (file, Redis or another solution)
- Use `client.destroy_session` to explicitly remove the session

### Create client once

```ruby
require 'sma_api'

client = SmaApi::Client.new(host: 'inverter address', password: 'password')

while true do
  # Current production
  puts client.get_values(['6100_40263F00'])
  sleep 5
end
```

### Cache the session id

In case the `sid` is not valid anymore, the client will try to create a new session.

```ruby
require 'sma_api'

# Cache the sid in this file
sid_file = '/tmp/sma_sid.txt'

sid = File.read(sid_file).chop rescue ''

client = SmaApi::Client.new(host: ENV['SMA_API_HOST'], password: ENV['SMA_API_WEB_PASSWORD'], sid: sid)

while true do
  current_yield = client.get_values(['6100_40263F00'])

  # If sid has been changed, save it to the sid file
  if client.sid != sid
    File.open(sid_file, 'w') { |f| f.puts sid }
  end

  puts "#{Time.now}\tCurrent yield: #{current_yield}"

  sleep 2
end
```

### Use destroy_session

This is the same as logging out from the web interface.

```ruby
require 'sma_api'

client = SmaApi::Client.new(host: 'inverter address', password: 'password', sid: sid)

# Current production
puts client.get_values(['6100_40263F00'])

client.destroy_session

# or:
at_exit { client.destroy_session }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rutgerw/sma_api.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
