# htt_expert_lua
This script was designed as simple solution for determining HTTP response time. It is written in LUA and designed to run with Tshark. 

Usage:
tshark -r "(filename)" -2 -X lua_script:http_expert.lua -q > (filename.csv)

	filename = capture file
  filename.csv = destination csv. The output of this script is CSV for easy import into spreadsheet program such as Excel. While it is     possible to output to terminal, file redirection (>) is encouraged due to variable field length and readability concerns.

Please feel free to share any suggestions, comments or other feedback.
