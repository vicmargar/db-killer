#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'

Bundler.require

$client = Mysql2::Client.new(:username => 'root')
$client.query("USE killer")

start_date = Date.parse(ARGV[0])
end_date = Date.parse(ARGV[0])

results = $client.query <<EOF
  SELECT ref, SUM(v) AS total FROM killer
  WHERE
    date BETWEEN "#{start_date}" AND "#{end_date}"
  GROUP BY ref
  ORDER BY total
EOF
puts "------------------"
puts "|    Ref | Total |"
puts "------------------"

results.each(:symbolize_keys => true) do |row|
  puts "| #{row[:ref].to_s.rjust 6} | #{row[:total].to_i.to_s.rjust 5} |"
end

puts "------------------"
