require 'socket'

=begin
(class ParseRequest)

The request to be parsed follows this structure

method path version
GET     /    HTTP/1.1
headers
Host: example.com
User-Agent: curl/..
Accept: */*

Request data is separated via newlines \r\n
=end


class ParseRequest
    def self.parse(request)
        method, path, version = 
            request.lines[0].split

            {
                path: path,
                method: method,
                headers: parse_headers(request)
            }
    end

    def self.normalize(header)
             header.gsub(":", "").downcase.to_sym
        end

    def self.parse_headers(request)
        headers = {}

        #Start at line 1 and end in the last line
        #in each line we have a header and it's value
        #we make a hash of headers where the header and
        #it's corresponding value are stored in a readable format
        request.lines[1..-1].each do
            |line|
            return headers if line == "\r\n"

            header, value = line.split
            header = normalize(header)

            headers[header] = value


        
    end
    

end

#Check if a file is available if it isn't send a 
#404 response if it is send a 200 response 
class PrepareResponse
    
    SERVER_ROOT = "/home/yoda45/Desktop/Projects/CAOS/RubyServer/"

    def self.prepare(request)
        
        #change to // to see bad request
        if request.fetch(:path) == "/"
            respond_with(SERVER_ROOT + "index.html")
        else
            bad_req(File.binread(SERVER_ROOT + "reqb.html"))
        end
    end

    def self.respond_with(path)

        if File.exists?(path)
            send_ok(File.binread(path))
        else
            #erase index.html to see 404 page
            send_file_not_found(File.binread(SERVER_ROOT+"bad.html"))
        end
    end

    def self.send_ok(data)
        Response.new(code: 200, data: data)
    end

    def self.send_file_not_found(data)
        Response.new(code:404, data: data)
    end
    
    def self.bad_req(data)
        Response.new(code:400, data:data)
    end
end

class Response
    def initialize(code:,data:"")
        @codi = "#{code}"
        @response=
        "HTTP/1.1 #{code}\r\n" +
        "Content-Length: #{data.size}\r\n" +
        "\r\n" +
        "#{data}\r\n"
    end

    def get
        return @codi
    end 

    def send(client)
        client.write(@response)
    end
end






#create new server socket bound to port
server = TCPServer.new('127.0.0.1',4545)

loop{
    client = server.accept
    request = client.readpartial(2048)

    request = ParseRequest.parse(request)
    response = PrepareResponse.prepare(request)



    puts "#{client.peeraddr[3]} #{request.fetch(:path)} #{response.get}"

    response.send(client)
    client.close
}
end
