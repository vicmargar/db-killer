#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'benchmark'

Bundler.require

$client = Mysql2::Client.new(:username => 'hst')
$client.query("USE killer")

if ARGV.length == 3
  start_date = Date.parse(ARGV[0])
  end_date = Date.parse(ARGV[1])
  guests = ARGV[2].to_i
else
  start_date = Date.today
  end_date = Date.today + 45
  guests = 1
end

time = Benchmark.realtime do
query =<<EOF
    SELECT room_id, SUM(price) AS total, MIN(available) as available FROM killer
    WHERE
      date BETWEEN "#{start_date}" AND "#{end_date}"
    GROUP BY room_id
    HAVING
      MIN(available) >= #{guests}
    ORDER BY total
EOF
puts query
$results = $client.query query
end
puts "Query took #{time}s"
puts "------------------------------"
puts "| RoomId | Total | Available |"
puts "------------------------------"

$results.each(:symbolize_keys => true) do |row|
  puts "| #{row[:room_id].to_s.rjust 6} | #{row[:total].to_i.to_s.rjust 5} | #{row[:available].to_i.to_s.rjust 9} |"
end

puts "------------------------------"
