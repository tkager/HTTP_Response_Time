--- HTTP Stats
--- Created by Thomas Kager
--- tkager@linux.com
--- Last modified 3/11/16

--[[
The purpose of this script is to act as a simple http response time measurement tool. In summary, it measures the time delta between the initial request and HTTP response frames.

- Usage
tshark -r "(filename)" -2 -X lua_script:http_expert.lua -q > (filename.csv)

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
http_request_time=Field.new("frame.time")
http_request_frame=Field.new("frame.number")
client=Field.new("ip.src")
server=Field.new("ip.dst")
http_request_method=Field.new("http.request.method")
http_request_version=Field.new("http.request.version")
http_user_agent=Field.new("http.user_agent")
http_host=Field.new("http.host")
http_request_uri=Field.new("http.request.uri")
http_data=Field.new("http")
http_request_header_fields=0

--- From response
http_reply_frame=Field.new("frame.number")
http_request_in=Field.new("http.request_in")
http_response_code=Field.new("http.response.code")
http_cache_control=Field.new("http.cache_control")
http_time=Field.new("http.time")

function tap.draw()
--- Header Output. Needs to occur before main loop or, we will have header for each row!
io.write("request frame",",","request time",",","client",",","server",",","request methood",",","request version",",","http host",",","request uri",",","user agent",",","request header fields",",","response frame",",","response code",",","response time",",","cache control")
io.write("\n") --- linespace after header

--- Main Loop
for k,v in pairs (http) do
--- Optimal to combine these into a single IO write.
io.write(tostring(k),",",tostring(http[k][http_request_time]),",",tostring(http[k][client]),",",tostring(http[k][server]),",",tostring(http[k][http_request_method]),",",tostring(http[k][http_request_version]),",",tostring(http[k][http_host]),",",tostring(http[k][http_request_uri]),",",tostring(http[k][http_user_agent]),",",tostring(http[k][http_request_header_fields]),",")
io.write(tostring(http[k][http_reply_frame]),",",tostring(http[k][http_response_code]),",",tostring(http[k][http_time]),",",tostring(http[k][http_cache_control]))
io.write("\n") --- linespace after row

end

end -- end tap.draw()


function tap.packet() --- Wireshark/Tshark looks for tap.packet() and calls it for each frame that matches listener filter.

--- Set common Variables for use within tap.packet()

if http_request_method() then

	request_frame=tostring(http_request_frame())
	http[request_frame]={}
	http[request_frame][http_request_time]=tostring(http_request_time()):gsub(',','')
	http[request_frame][client]=tostring(client())
	http[request_frame][server]=tostring(server())
	http[request_frame][http_request_method]=tostring(http_request_method())
	http[request_frame][http_request_version]=tostring(http_request_version())
	http[request_frame][http_host]=tostring(http_host())
	http[request_frame][http_request_uri]=tostring(http_request_uri())

	--- Determine Number of Request Header Fields. Method,URI and Version is counted as one field.
	x=tostring(http_data())
	_, count = string.gsub(x, "0d:0a", " ")
	_, double_white = string.gsub(x, "0d:0a:0d:0a", " ")
	http[request_frame][http_request_header_fields]=count - double_white - 1
	--- Add user_agent if present within headers
	if http_user_agent() == nil then
		http[request_frame][http_user_agent]="none"
	else
		http[request_frame][http_user_agent]=tostring(http_user_agent())
	end

else if http_response_code() then
	request_in=tostring(http_request_in())
	http[request_in][http_reply_frame]=tostring(http_reply_frame())
	http[request_in][http_response_code]=tostring(http_response_code())
	http[request_in][http_time]=tostring(http_time())
	--- Check for cache control
	if http_cache_control() == nil then
		http[request_in][http_cache_control]="none"
	else
		http[request_in][http_cache_control]=tostring(http_cache_control()):gsub(',','')
	end

else
	end


end

end --- end of tap_packet()
