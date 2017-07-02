print '----- Welcome to Q! ------'

local repl = require 'Q/Q_REPL/start_repl'
local eval = require 'Q/Q_REPL/q_eval_line'
local res_str = require 'Q/Q_REPL/q_res_str'

print (#arg)
if (#arg == 0) then
    repl (function (line)
        local success, results = eval(line)
        if success then
            return res_str(results)
        else
            return tostring(results[1])
        end
    end)
elseif (#arg == 2) then 
    -- act as http client
    local host = arg[1]
    local port = arg[2]
    local uri = "http://" .. host .. ":" .. port
    print ("----- Remotely connected to Q-server at " .. uri)
    local request = require "http.request"
    local req_timeout = 10
    repl (function (line)
        local req = request.new_from_uri(uri)
        req.headers:upsert(":method", "POST")
	    req:set_body(line)
        local headers, stream = req:go(req_timeout)
        if headers == nil then
            io.stderr:write(tostring(stream), "\n")
            os.exit(1)
        end
        local body, err = stream:get_body_as_string()
        if not body and err then
            io.stderr:write(tostring(err), "\n")
            os.exit(1)
        end
        return body   
    end)
else
    print "USAGE .... ?!!"
end
