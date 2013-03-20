#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'

Bundler.require

$client = Mysql2::Client.new(:username => 'root')
$client.query("DROP DATABASE IF EXISTS killer")
$client.query("CREATE DATABASE killer")
$client.query("USE killer")

def kill(count, days)
  $client.query("DROP TABLE IF EXISTS killer")
  $client.query("CREATE TABLE killer (id INTEGER NOT NULL AUTO_INCREMENT, ref INTEGER NOT NULL, date DATE NOT NULL, price INTEGER NOT NULL, available INTEGER NOT NULL, PRIMARY KEY (id)) ENGINE=InnoDB;")
  count.times do |ref|
    price = rand(20..120)
    available = rand(1..5)

    values = []
    days.times do |i|
      date = Date.today + i
      date_price = price - rand(-10..10)
      date_available = available - rand(0..available)

      values << "(#{ref}, '#{date}', #{date_price}, #{date_price})"
    end
    $client.query("INSERT INTO killer (ref, date, price, available) VALUES#{values.join(',')}")
  end
end

kill(1000, 1000)
