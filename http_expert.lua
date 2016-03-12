--- HTTP Stats
--- Created by Thomas Kager
--- tkager@linux.com
--- Last modified 3/11/16

--[[
The purpose of this script is to act as a simple http response time measurement tool. In summary, it measures the time delta between the initial request and HTTP response frames.

- Usage
tshark -R "http.request.method || http.response.code" -r "(filename)" -2 -X lua_script:http_expert.lua -q > (filename.csv)

filename = capture file
filename.csv = destination csv. The output of this script is CSV for easy import into spreadsheet program such as Excel.

Requires Wireshark/Tshark 1.10 or later with LUA compiled
--]]

--- Create Listener. The filter is HTTP, though this is likely unnecessary, as we are filtering from the CLI.
tap=Listener.new(nil, "http")

-- Create usrdata array http.
http = {}

--- Field Extractors are used to map tshark fields to variables and behave as function calls

--- From request
http_request_frame=Field.new("frame.number")
http_request_method=Field.new("http.request.method")
http_request_version=Field.new("http.request.version")
http_host=Field.new("http.host")
http_request_uri=Field.new("http.request.uri")

--- From response
http_reply_frame=Field.new("frame.number")
http_request_in=Field.new("http.request_in")
http_response_code=Field.new("http.response.code")
http_time=Field.new("http.time")

function tap.draw()
--- Header Output. Needs to occur before main loop or, we will have header for each row!
io.write("request frame", ",", "request methood" , "," , "request version" , ",", "http host" , "," , "request uri" , "," , "response frame" , "," , "response code" , "," , "response time")
io.write("\n") --- linespace after header

--- Main Loop
for k,v in pairs (http) do
--- Optimal to combine these into a single IO write.
io.write(tostring(k), "," , tostring(http[k][http_request_method]), "," , tostring(http[k][http_request_version]), "," , tostring(http[k][http_host]), "," , tostring(http[k][http_request_uri]), ",")
io.write(tostring(http[k][http_reply_frame]), "," , tostring(http[k][http_response_code]), "," , tostring(http[k][http_time]))
io.write("\n") --- linespace after row

end

end -- end tap.draw()


function tap.packet() --- Wireshark/Tshark looks for tap.packet() and calls it for each frame that matches listener filter.

--- Set common Variables for use within tap.packet()

if http_request_method() then

	request_frame=tostring(http_request_frame())
	http[request_frame]={}
	http[request_frame][http_request_method]=tostring(http_request_method())
	http[request_frame][http_request_version]=tostring(http_request_version())
	http[request_frame][http_host]=tostring(http_host())
	http[request_frame][http_request_uri]=tostring(http_request_uri())

else
	request_in=tostring(http_request_in())
	http[request_in][http_reply_frame]=tostring(http_reply_frame())
	http[request_in][http_response_code]=tostring(http_response_code())
	http[request_in][http_time]=tostring(http_time())
end

end --- end of tap_packet()
