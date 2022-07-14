#!/usr/bin/env ruby

require 'bigdecimal'
require 'tiny_tds'

begin
  $client = TinyTds::Client.new(username: 'px', password: 'px', host: '172.20.30.199', database: 'px')
  puts('Connected')

  result = $client.execute('SELECT * FROM [sessions]')

  result.each do |row|
    puts(row)
    # -> {"session_id"=>1, "client_id"=>"192.168.203.100", "y"=>1, "last_login"=>111, "comment"=>nil}
    puts("#{row['client_id']}, #{row['last_login']}, #{row['y']}")
  end
rescue StandardError => e
  puts(e)
  puts(e.inspect)
end
