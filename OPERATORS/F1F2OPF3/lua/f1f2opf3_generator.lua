#!/usr/bin/env lua

package.path = package.path.. ";../../../UTILS/lua/?.lua"
require("aux")

dofile '../../../UTILS/lua/globals.lua'

local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
local T = dofile 'f1f2opf3_operators.lua' 
local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

args = nil -- not being used just yet
for i, v in ipairs(T) do
  local base_name = v
  local str = 'require \'' .. base_name .. '_static_checker\''
--  require concat_static_checker.lua
  loadstring(str)()
  for i, in1type in ipairs(types) do 
    for j, in2type in ipairs(types) do 
      for k, returntype in ipairs(types) do 
        stat_chk = base_name .. '_static_checker'
        assert(_G[stat_chk], "function not found " .. stat_chk)
        -- print("Lua premature", stat_chk); os.exit()
        local subs, incs, tmpl = 
        _G[stat_chk](in1type, in2type, returntype, args)
        if ( subs ) then
          local B = nil; local W = nil
          if ( file_exists(base_name .. "_black_list.lua")) then 
            B = dofile(base_name .. "_black_list.lua")
          end
          if ( file_exists(base_name .. "_white_list.lua")) then 
            local w = dofile(base_name .. "_white_list.lua")
            W = {}
            for i, v in ipairs(w) do
              W[v] = true
            end
          end
          if ( W and B ) then 
            error("Cannot have both black and white list")
          end
          -- TODO Improve following.
          local T = dofile(tmpl)
          T.fn         = subs.fn
          T.in1type    = subs.in1type
          T.in2type    = subs.in2type
          T.returntype = subs.returntype
          T.argstype   = subs.argstype
          T.c_code_for_operator = subs.c_code_for_operator
          -- process black/white lists
          local skip = false; local decided = false
          if ( ( B == nil ) and ( W == nil ) ) then 
            skip = false
            decided = true
          end
          if ( ( B ~= nil ) and ( decided == false ) ) then
            if B[fn] then skip = true else skip = false end 
            decided = true
          end
          if ( ( W ~= nil ) and ( decided == false ) ) then
            if W[fn] then skip = false else skip = true end 
            decided = true
            if ( skip == true ) then print("Skipping ", fn) end
          end
          if not decided then error("Control cannot come here") end
          if not skip then 
          doth = T 'declaration'
          -- print("doth = ", doth)
          local fname = incdir .. "_" .. subs.fn .. ".h", "w"
          local f = assert(io.open(fname, "w"))
          f:write(doth)
          if ( includes ) then 
            for i, v in ipairs(includes) do
              f:write("#include <" .. v .. ".h>\n")
            end
          end
          f:close()
          dotc = T 'definition'
          -- print("dotc = ", dotc)
          local fname = srcdir .. "_" .. subs.fn .. ".c", "w"
          local f = assert(io.open(fname, "w"))
          f:write(dotc)
          f:close()
        end
      else
        -- print("Invalid combo ", in1type, " ", in2type, " ", outtype1)
        end
      end
    end
  end
end
