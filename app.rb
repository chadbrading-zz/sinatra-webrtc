require 'thin'
require 'sinatra/base'
require 'em-websocket'

EventMachine.run do
  class App < Sinatra::Base
    @@websocket_url = 'ws://localhost:3001'

    get '/' do
      @websocket_url = @@websocket_url
      erb :call
    end

    get '/answer' do
      @websocket_url = @@websocket_url
      erb :answer
    end

    get '/stop' do
      EventMachine.stop
    end
  end

  @clients = []

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      @clients.push ws
      puts "Connected to #{handshake.path}."
    end

    ws.onclose do
      puts "Closed."
      @clients.delete ws
    end

    ws.onmessage do |msg|
      puts "Received Message: #{msg}"
      @clients.each do |socket|
        socket.send msg
      end
    end
  end

  App.run! :port => 3000
end

