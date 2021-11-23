#!/usr/bin/env ruby
# Id$ nonnax 2021-11-12 23:41:51 +0800
require 'excon'
require 'json'
require 'rubytools/array_table'
require 'rubytools/arraycsv'

def update(coin, days=1)
# days = 7 unless days
  res= Excon.get "https://api.coingecko.com/api/v3/coins/#{coin}/ohlc?vs_currency=php&days=#{days}"
  p body=JSON.parse(res.body)
  data=ArrayCSV.new("#{coin}_#{days}.csv", 'w')
  data<<%w[date open high low close]
  body.each do |r|
    r[0]=Time.at(r[0].to_i/1000)
    data<<r  
  end
end

threads=[]
coin_list=%w[bitcoin ethereum bitcoin-cash chainlink litecoin ripple uniswap]

coin_list.each_with_index do |c, i|
  threads << Thread.new{update(c)}
  threads << Thread.new{update(c, 7)}
  sleep 0.5
  print [i+1,coin_list.size].join('/')+"\r"
end

threads.each{|t| t.join }

puts

threads=[]
coin_list.each do |c|
  threads<<Thread.new{ IO.popen("erb filename='#{c}_1.csv' ./genchart.erb  > 'views/#{c}.html'", &:read)}
  threads<<Thread.new{IO.popen("erb filename='#{c}_7.csv' ./genchart.erb  > 'views/#{c}_7.html'", &:read)}
end
threads.each{|t| t.join}
