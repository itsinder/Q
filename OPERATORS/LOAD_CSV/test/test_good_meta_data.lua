-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'
local validate_meta = require("Q/OPERATORS/LOAD_CSV/lua/validate_meta")

local tests = {}

local script_dir = plpath.dirname(plpath.abspath(arg[1]))
local meta_data_file = script_dir .. "/good_meta_data.lua"
local T = dofile(meta_data_file)

for i, gm in ipairs(T) do
  -- here index to tests table is i
  tests[i] = function ()
    local metadata
    if not plpath.isabs(gm) then
      metadata = script_dir .."/".. gm
    end
    print("Testing " .. gm)
    local M = dofile(metadata)
    local status, err = pcall(validate_meta, M)
    if ( not status ) then 
      print("Error:", err)
    end
    print("validated meta_data: " .. gm .. " successfully")
  end
end

return tests