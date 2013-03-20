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
    SELECT hosts.id as host_id, rooms.id AS room_id, tmp.total AS total, tmp.available AS available FROM hosts INNER JOIN (SELECT host_id, room_id, SUM(price) AS total, MIN(available) as available FROM killer
    WHERE
      date BETWEEN "#{start_date}" AND "#{end_date}"
    GROUP BY room_id
    HAVING
      MIN(available) >= #{guests}) AS tmp ON tmp.host_id = hosts.id
    INNER JOIN rooms ON rooms.host_id = hosts.id
    ORDER BY total
    LIMIT 5
EOF
puts query
$results = $client.query query
end
puts "Query took #{time}s"
puts "-----------------------------------------"
puts "| host_id | room_id | total | available |"
puts "-----------------------------------------"

$results.each(:symbolize_keys => true) do |row|
  puts "| #{row[:host_id].to_s.rjust 7} | #{row[:room_id].to_s.rjust 7} | #{row[:total].to_i.to_s.rjust 5} | #{row[:available].to_i.to_s.rjust 9} |"
end

puts "-----------------------------------------"
