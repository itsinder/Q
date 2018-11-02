local tablex = require 'pl.tablex'
local utils = require 'Q/UTILS/lua/utils'

local write_to_csv = function(result, csv_file_path, sep)
  assert(result)
  assert(type(result) == "table")
  assert(csv_file_path)
  assert(type(csv_file_path) == "string")
  sep = sep or ','
  
  local file = assert(io.open(csv_file_path, "w"))

  local required_param = {"f1_score","nodes","precision","recall","mcc","c_d_score","accuracy","gain","cost", "nodes"}
  local tbl = {}
  for i, v in pairs(result) do
    if utils["table_find"](required_param, i) ~= nil then 
      tbl[i] = v
    end
  end
  --local plpretty = require "pl.pretty"
  --plpretty.dump(tbl)
  
  --file:write("alpha,accuracy,precision,recall,f1_score,c_d_score,gain,cost,nodes,mcc\n")
  file:write("cost,c_d_score,f1_score,accuracy,mcc,precision,gain,recall\n")
  for i,v in pairs(tbl) do
    file:write(v)
    file:write(',')
  end

  file:close()
end

return write_to_csv
