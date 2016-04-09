#!/usr/bin/env ruby
require 'oanda_api'

TARGET_PAIRS = %w(USD_JPY)

client = OandaAPI::Client::TokenClient.new(:practice, ENV["OANDA_DEMO_API_KEY"])

prices = client.prices(instruments: TARGET_PAIRS).get

prices.each do |price|
  puts "#{price.instrument.gsub(/_/, '')}: #{price.ask}"
  price.instrument       # => "EUR_USD"
  price.ask              # => 1.13781
  price.bid              # => 1.13759
  price.time             # => 2015-01-27 21:01:13 UTC
end
