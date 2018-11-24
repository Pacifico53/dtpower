require 'socket'

SERVER_ROOT = "."
PORT = 8080
socket = TCPServer.new('localhost', PORT)

def handle_connection(client)
    puts "New client! #{client}"
    #request = client.readpartial(2048)
    #request = parser(request)
    #response = respond_with(prepare_response(request))
    #falta aqui meter a maneira de como o server responde

    client.write("Server says hello!")
    client.close
end

puts "Listening on localhost:#{PORT}. Press CTRL+C to cancel."

#TODO HTML REQUEST PARSER
#def parser(request)
#end

def prepare_response(request)
    if request.fetch(:path) == "/"
        respond_with(SERVER_ROOT + "server.rb")
    else
        respond_with(SERVER_ROOT + request.fetch(:path))
    end
end

def respond_with(path)
    if File.exists?(path)
        send_ok_response(File.binread(path))
    else
        send_file_not_found
    end
end

class Response
    def initialize(code:, data: "")
        @response =
        "HTTP/1.1 #{code}\r\n" +
        "Content-Length: #{data.size}\r\n" +
        "\r\n" +
        "#{data}\r\n"
    end

    def send(client)
        client.write(@response)
    end
end

def send_ok_response(data)
    Response.new(code: 200, data: data)
end

def send_file_not_found
    Response.new(code: 404)
end

def send_bad_request
    Response.new(code: 400)
end

loop do
    client = socket.accept
    Thread.new { handle_connection(client) }
end
