#!/usr/bin/env lua

package.path = package.path.. ";../../UTILS/lua/?.lua"
require("aux")

dofile '../../UTILS/lua/globals.lua' -- do not hard code locations

local srcdir = "../../PRIMITIVES/src/" 
local incdir = "../../PRIMITIVES/inc/" 
local T = dofile 'f1f2opf3_operators.lua' 
local tmpl = dofile 'f1f2opf3.tmpl'
-- Improve following
local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

for i, v in ipairs(T) do
  local base_name = v
  local str = 'require \'' .. base_name .. '_static_checker\''
  --  require concat_static_checker.lua
  load(str)()
  for i, in1type in ipairs(types) do 
    for j, in2type in ipairs(types) do 
      for k, returntype in ipairs(types) do 
        stat_chk = base_name .. '_static_checker'
        assert(_G[stat_chk], "no checker for " .. base_name)
        -- subs = substitutions, incs = includes
        local subs, incs = 
        _G[base_name .. '_static_checker'](in1type, in2type, returntype)
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
          tmpl.fn = subs.fn
          tmpl.in1type = subs.in1type
          tmpl.in2type = subs.in2type
          tmpl.returntype = subs.returntype
          tmpl.scalar_op = subs.scalar_op
          local fn = tmpl.fn
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
          end
          if not decided then error("Control cannot come here") end
          if skip then 
            print("Skipping ", fn) 
          else
            -- print(tmpl 'declaration')
            doth = tmpl 'declaration'
            -- print("doth = ", doth)
            local fname = incdir .. "_" .. subs.fn .. ".h", "w"
            local f = assert(io.open(fname, "w"))
            f:write(doth)
            if ( incs ) then 
              for i, v in ipairs(incs) do
                f:write("#include <" .. v .. ".h>\n")
              end
            end
            f:close()
            -- print(tmpl 'definition')
            dotc = tmpl 'definition'
            -- print("dotc = ", dotc)
            local fname = srcdir .. "_" .. subs.fn .. ".c", "w"
            local f = assert(io.open(fname, "w"))
            f:write(dotc)
            f:close()
          end
        else
          print("Invalid combo ", in1type, " ", in2type, " ", returntype)
        end
      end
    end
  end
end
