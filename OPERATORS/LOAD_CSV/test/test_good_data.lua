-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'
local load_csv = Q.load_csv

local script_dir = plpath.dirname(plpath.abspath(arg[0]))
local meta_data_file = script_dir .. "/good_data.lua"
T = dofile(meta_data_file)
for i, v in ipairs(T) do
  if not plpath.isabs(v.meta) then 
    v.meta = script_dir .."/".. v.meta
    v.data = script_dir .."/".. v.data
  end
  M = dofile(v.meta)
  D = v.data
  status, err = pcall(load_csv, D, M)
  if ( not status ) then 
    error( "Failed on M, D".. err)
  end
end
print("Load CSV : Success")
require('Q/UTILS/lua/cleanup')()
os.exit()
