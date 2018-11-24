require 'socket'

PORT = 8080
socket = TCPServer.new('localhost', PORT)

def handle_connection(client)
    puts "New client! #{client}"
    client.write("Server says hello!")
    client.close
end

puts "Listening on localhost:#{PORT}. Press CTRL+C to cancel."

loop do
    client = socket.accept
    Thread.new { handle_connection(client) }
end
