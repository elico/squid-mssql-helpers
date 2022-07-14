#!/usr/bin/env ruby

# license note
# Copyright (c) 2022, Eliezer Croitoru
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'bigdecimal'
require 'tiny_tds'

active_login = true
$debug = false
$minutes = 30

begin
  $client = TinyTds::Client.new(username: 'px', password: 'px', host: '172.20.30.199', database: 'px')
  result = $client.execute('SELECT * FROM [sessions]')
  $client.close unless $client.closed?
  warn('#STDERR#: Connected')
rescue StandardError => e
  puts(e)
  puts(e.inspect)
end

def login(ip)
  exists = 0
  begin
    client = TinyTds::Client.new(username: 'px', password: 'px', host: '172.20.30.199', database: 'px')
  rescue StandardError => e
    warn(e)
    warn(e.inspect)
  end

  query = "INSERT INTO [dbo].[sessions] ([client_id], [last_login]) VALUES ( '##CLIENT_ID##', ##LAST_LOGIN## );"
  query = <<~EOF
    BEGIN TRY
      INSERT INTO [dbo].[sessions] ([client_id], [last_login]) VALUES ( '##CLIENT_ID##', ##LAST_LOGIN## );
    END TRY
    BEGIN CATCH
        UPDATE [dbo].[sessions] SET [last_login] = ##LAST_LOGIN## WHERE [client_id] = '##CLIENT_ID##';
    END CATCH
  EOF
  q = query.gsub('##CLIENT_ID##', ip).gsub('##LAST_LOGIN##', Time.now.to_i.to_s)

  begin
    result = client.execute(q).do
  rescue StandardError => e
    warn(e)
    warn(e.inspect)
  end

  client.close unless client.closed?
end

def logout(ip)
  begin
    client = TinyTds::Client.new(username: 'px', password: 'px', host: '172.20.30.199', database: 'px')
  rescue StandardError => e
    warn(e)
    warn(e.inspect)
  end

  begin
    query = "UPDATE [dbo].[sessions] SET [last_login] = 0 WHERE [client_id] = '##CLIENT_ID##';"
    result = client.execute(query.gsub('##CLIENT_ID##', ip)).do
  rescue StandardError => e
    warn(e)
    warn(e.inspect)
  end
  client.close unless client.closed?
end

def gettime(ip)
  res = 0
  begin
    client = TinyTds::Client.new(username: 'px', password: 'px', host: '172.20.30.199', database: 'px')
  rescue StandardError => e
    warn(e)
    warn(e.inspect)
  end
  query = "SELECT * FROM [dbo].[sessions] WHERE [client_id] = '##CLIENT_ID##';"
  begin
    result = client.execute(query.gsub('##CLIENT_ID##', ip))
    result.each do |row|
      res = Time.at(row['last_login']) unless row['last_login'].nil?
    end
  rescue StandardError => e
    warn(e)
    warn(e.inspect)
  end
  client.close unless client.closed?
  res
end

STDOUT.sync = true

while line = STDIN.gets
  id, ip, login = line.chomp.split
  warn "request details: {id=> \" #{id}\", ip=> \"#{ip}\", login=> \"#{login == 'LOGIN'}\"}" if $debug
  if login && login == 'LOGIN'
    login(ip)
    STDOUT.puts "#{id} OK message=\"Welcome\""
  elsif login && login == 'LOGOUT'
    logout(ip)
    STDOUT.puts "#{id} OK message=\"ByeBye\""
  else
    current = gettime(ip)
    calc = (Time.now - current).to_i
    if calc > ($minutes * 60)
      STDOUT.puts "#{id} ERR message=\"No session available\""
    else
      STDOUT.puts "#{id} OK message=\"passed: #{calc} seconds\""
    end
  end
end
