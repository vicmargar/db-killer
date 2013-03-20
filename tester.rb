#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'benchmark'

Bundler.require

$client = Mysql2::Client.new(:username => 'root')
$client.query("USE killer")

if ARGV.length == 2
  start_date = Date.parse(ARGV[0])
  end_date = Date.parse(ARGV[1])
else
  start_date = Date.today
  end_date = Date.today + 45
end

time = Benchmark.realtime do
  $results = $client.query <<EOF
    SELECT ref, SUM(price) AS total FROM killer
    WHERE
      date BETWEEN "#{start_date}" AND "#{end_date}"
    GROUP BY ref
    ORDER BY total
EOF
end
puts "Query took #{time}s"
puts "------------------"
puts "|    Ref | Total |"
puts "------------------"

$results.each(:symbolize_keys => true) do |row|
  puts "| #{row[:ref].to_s.rjust 6} | #{row[:total].to_i.to_s.rjust 5} |"
end

puts "------------------"
