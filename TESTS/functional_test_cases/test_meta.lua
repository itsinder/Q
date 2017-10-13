local Q = require 'Q'
require 'Q/UTILS/lua/strict'


local M = dofile("meta_data.lua")
x = Q.load_csv("data.csv", M, { is_hdr = true, use_accelerator = false})

--Q.print_csv(x, nil, "")
--io.output("meta_data.txt")
for i = 1, #x do
local T = x[i]:meta()
for k,v in pairs(T.base) do print(k,v) end
for k,v in pairs(T.aux) do print(k,v) end
end

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.execute("rm _*.bin") 
os.exit()
