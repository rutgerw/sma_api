# This scripts shows current yield, every 2 seconds
require 'sma_api'

sid_file = '/tmp/sma_sid.txt'

sid = File.read(sid_file).chop rescue ''

client = SmaApi::Client.new(host: ENV['SMA_API_HOST'], password: ENV['SMA_API_WEB_PASSWORD'], sid: sid)

while true do
  current_yield = client.get_values(['6100_40263F00'])

  # If session id has been changed, save it to the sid_file
  if client.sid != sid
    File.open(sid_file, 'w') { |f| f.puts sid }
  end

  puts "#{Time.now}\tCurrent yield: #{current_yield}"

  sleep 2
end
