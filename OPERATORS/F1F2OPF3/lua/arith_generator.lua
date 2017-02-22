#!/usr/bin/env lua

  package.path = package.path.. ";../../../UTILS/lua/?.lua"
  require("aux")
  require("gen_doth")
  require("gen_dotc")
  local pl = require 'pl'
  -- pl.unlink("_qfns_f1f2opf3.lua")

  dofile '../../../UTILS/lua/globals.lua'

  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  local operator_file = assert(arg[1])
  assert(file_exists(operator_file))
  local T = dofile(operator_file)
  local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

  args = nil -- not being used just yet
  for i, v in ipairs(T) do
    -- ==================
    local str = "function " .. v .. "(f1, f2, optargs)\n"
    str = str .. "  expander(\"f1f2opf3\", \"" .. v .. "\", f1, f2, optargs)\n"
    str = str .. "end\n"
    local f = assert(io.open("_qfns_f1f2opf3.lua", "a"))
    f:write(str)
    f:close()
    -- ==================

    local base_name = v
    local str = 'require \'' .. base_name .. '_static_checker\''
    --  require concat_static_checker.lua
    loadstring(str)()
    for i, in1type in ipairs(types) do 
      for j, in2type in ipairs(types) do 
          local stat_chk = base_name .. '_static_checker'
          local stat_chk_fn = assert(_G[stat_chk], 
          "function not found " .. stat_chk)
          -- print("Lua premature", stat_chk); os.exit()
          local subs, tmpl = stat_chk_fn(in1type, in2type, optargs)
          if ( subs ) then 
          assert(tmpl)
            -- TODO Improve following.
            local T = dofile(tmpl)
            T.fn         = subs.fn
            T.includes   = subs.includes
            T.in1type    = subs.in1type
            T.in2type    = subs.in2type
            T.returntype = subs.returntype
            T.argstype   = subs.argstype
            T.c_code_for_operator = subs.c_code_for_operator
            gen_doth(T.fn, T, incdir)
            gen_dotc(T.fn, T, srcdir)
          end
        end
    end
  end
