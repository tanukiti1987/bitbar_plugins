#!/usr/bin/env ruby
require 'oanda_api'

class Integer
  def jpy_comma
    self.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
  end
end

MAIN_PAIR = ["USD_JPY"]
SUB_PAIRS = %w(EUR_USD)

client = OandaAPI::Client::TokenClient.new(:practice, ENV["OANDA_DEMO_API_KEY"])

price = client.prices(instruments: MAIN_PAIR).get.first
puts "#{price.instrument.gsub(/_/, '')}: #{price.ask}"
puts "---"

prices = client.prices(instruments: SUB_PAIRS).get
prices.each_with_index do |price, i|
  puts "#{price.instrument.gsub(/_/, '')}: #{price.ask}"
end

accounts = client.accounts.get

accounts.each do |a|
  puts "#{a.account_name}"

  account = client.account(a.account_id).get
  puts "口座資産: ¥#{(account.balance).round.jpy_comma}"
  puts "有効証拠金: ¥#{(account.balance + account.unrealized_pl).round.jpy_comma}"
  puts "評価損益: ¥#{account.unrealized_pl.round.jpy_comma}"

  begin
    position = client.account(a.account_id).position(MAIN_PAIR).get
    puts "#{price.instrument.gsub(/_/, '')}ポジション数: #{position.total_units.jpy_comma}"
  rescue OandaAPI::RequestError
    nil
  end

  unless SUB_PAIRS.empty?
    prices = client.prices(instruments: SUB_PAIRS).get
    prices.each_with_index do |price, i|
      begin
        position = client.account(a.account_id).position(price.instrument).get
        puts "#{price.instrument.gsub(/_/, '')}ポジション数: #{position.total_units}"
      rescue OandaAPI::RequestError
        nil
      end
    end
  end
end
