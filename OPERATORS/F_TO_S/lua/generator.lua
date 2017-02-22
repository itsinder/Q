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
    local str = "function " .. v .. "(f1, f2)\n"
    str = str .. "  expander(\"f1f2opf3\", \"" .. v .. "\", f1, f2)\n"
    str = str .. "end\n"
    local f = assert(io.open("_qfns_f1f2opf3.lua", "a"))
    f:write(str)
    f:close()
    -- ==================

    local base_name = v
    local str = 'require \'' .. base_name .. '_chk\''
    loadstring(str)()
    for i, intype in ipairs(types) do 
      local stat_chk = base_name .. '_chk'
      local stat_chk_fn = assert(_G[stat_chk], 
      "function not found " .. stat_chk)
      local subs, tmpl = stat_chk_fn(intype)
      assert(subs); assert(tmpl);
      if ( subs ) then 
        -- TODO Improve following.
        local T = dofile(tmpl)
        T.fn         = subs.fn
        T.intype    = subs.intype
        T.c_code_for_operator = subs.c_code_for_operator
        gen_doth(T.fn, T, incdir)
        gen_doth(T.fn, T, srcdir)
      end
    end
  end
