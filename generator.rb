#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'

Bundler.require

$client = Mysql2::Client.new(:username => 'root')
$client.query("DROP DATABASE IF EXISTS killer")
$client.query("CREATE DATABASE killer")
$client.query("USE killer")

def kill(params)
  hosts          = params[:hosts]
  rooms_per_host = params[:rooms_per_host]
  days           = params[:days]

  $client.query("DROP TABLE IF EXISTS killer")
  $client.query("DROP TABLE IF EXISTS hosts")
  $client.query("DROP TABLE IF EXISTS rooms")

  $client.query("CREATE TABLE hosts (id INTEGER NOT NULL, PRIMARY KEY (id)) ENGINE=InnoDB;")
  $client.query("CREATE TABLE rooms (id INTEGER NOT NULL, host_id INTEGER NOT NULL, capacity INTEGER NOT NULL, PRIMARY KEY (id)) ENGINE=InnoDB;")
  $client.query("CREATE TABLE killer (id INTEGER NOT NULL AUTO_INCREMENT, host_id INTEGER NOT NULL, room_id INTEGER NOT NULL, date DATE NOT NULL, price INTEGER NOT NULL, available INTEGER NOT NULL, PRIMARY KEY (id)) ENGINE=InnoDB;")

  $client.query("ALTER TABLE killer ADD INDEX killer_index(date, room_id, available, price, host_id);")

  host_values   = []
  room_values   = []
  killer_values = []

  hosts.times do |h|
    host_id = h + 1
    host_values << "(#{host_id})"

    rooms_per_host.times do |r|
      room_id = (host_id * rooms_per_host) - (rooms_per_host - r - 1)
      room_capacity = rand(2..4)
      room_price = rand(20..120)
      room_values << "(#{room_id}, #{host_id}, #{room_capacity})"

      days.times do |i|
        date = Date.today + i
        date_price = room_price - rand(-10..10)
        date_available = room_capacity - rand(0..room_capacity-1)
        killer_values << "(#{host_id}, #{room_id}, '#{date}', #{date_price}, #{date_available})"
      end
    end
  end

  $client.query("INSERT INTO hosts (id) VALUES#{host_values.join(',')}")
  $client.query("INSERT INTO rooms (id, host_id, capacity) VALUES#{room_values.join(',')}")

  killer_values.each_slice(1000) do |slice|
    $client.query("INSERT INTO killer (host_id, room_id, date, price, available) VALUES#{slice.join(',')}")
  end
end

# kill(hosts: 1000, rooms_per_host:2, days: 365)
kill(hosts: 5000, rooms_per_host:2, days: 100)