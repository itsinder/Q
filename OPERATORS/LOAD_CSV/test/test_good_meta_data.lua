-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'

local script_dir = plpath.dirname(plpath.abspath(arg[0]))
local meta_data_file = script_dir .. "/good_meta_data.lua"

local validate_meta = require("Q/OPERATORS/LOAD_CSV/lua/validate_meta")

T = dofile(meta_data_file)
for i, gm in ipairs(T) do
  if not plpath.isabs(gm) then
    gm = script_dir .."/".. gm
  end
  print("Testing " .. gm)
  M = dofile(gm)
  status, err = pcall(validate_meta, M)
  if ( not status ) then 
    print("Error:", err)
  end
end
print("Successfully completed")
require('Q/UTILS/lua/cleanup')()
os.exit()
