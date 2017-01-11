#!/usr/bin/env lua

package.path = package.path.. ";../?.lua"
require("aux")

dofile '../globals.lua'

local srcdir = "../../PRIMITIVES/src/" 
local incdir = "../../PRIMITIVES/inc/" 
local T = dofile 'f1f2opf3_operators.lua' 
local tmpl = dofile 'f1f2opf3.tmpl'
local types = { 'int8_t', 'int16_t', 'int32_t', 'int64_t','float', 'double' }

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
        local substitutions, includes = 
        _G[base_name .. '_static_checker'](in1type, in2type, returntype)
        if ( substitutions ) then
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
          tmpl.name = substitutions.name
          tmpl.in1type = substitutions.in1type
          tmpl.in2type = substitutions.in2type
          tmpl.returntype = substitutions.returntype
          tmpl.scalar_op = substitutions.scalar_op
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
          -- print(tmpl 'declaration')
          doth = tmpl 'declaration'
          -- print("doth = ", doth)
          local fname = incdir .. "_" .. substitutions.name .. ".h", "w"
          local f = assert(io.open(fname, "w"))
          f:write(doth)
          if ( includes ) then 
            for i, v in ipairs(includes) do
              f:write("#include <" .. v .. ".h>\n")
            end
          end
          f:close()
          -- print(tmpl 'definition')
          dotc = tmpl 'definition'
          -- print("dotc = ", dotc)
          local fname = srcdir .. "_" .. substitutions.name .. ".c", "w"
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
