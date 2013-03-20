#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'yaml'

Bundler.require

$client = Mysql2::Client.new(:username => 'root')
$client.query("DROP DATABASE IF EXISTS killer")
$client.query("CREATE DATABASE killer")
$client.query("USE killer")

def kill(count, days)
  $client.query("DROP TABLE IF EXISTS killer")
  $client.query("CREATE TABLE killer (id INTEGER NOT NULL AUTO_INCREMENT, ref INTEGER NOT NULL, date DATE NOT NULL, v INTEGER NOT NULL, c INTEGER NOT NULL, PRIMARY KEY (id)) ENGINE=InnoDB;")
  count.times do |ref|
    p = rand(20..120)
    c = rand(1..5)

    days.times do |i|
      date = Date.today + i
      vp = p - rand(-10..10)
      vc = c - rand(0..c)

      $client.query("INSERT INTO killer (ref, date, v, c) VALUES (#{ref}, '#{date}', #{vp}, #{vc})")
    end
  end
end

kill(1000, 1000)
