#!/usr/bin/env lua

  local rootdir = os.getenv("Q_SRC_ROOT")
  assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
  package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
  require("aux")
  require("gen_doth")
  require("gen_dotc")
  local plpath = require "pl.path"
  dofile '../../../UTILS/lua/globals.lua'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"

  local operator_file = assert(arg[1])
  assert(plpath.isfile(operator_file))
  local T = dofile(operator_file)
  local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

  for i, base_name in ipairs(T) do
    -- ==================
    local str = "function " .. base_name .. "(fld, scalar)\n"
    str = str .. "  expander(\"f1s1opf2\", \"" .. base_name .. "\", fld, scalar)\n"
    str = str .. "end\n"
    local f = assert(io.open("_qfns_f1s1opf2.lua", "a"))
    f:write(str)
    f:close()
    -- ==================
    print(base_name)
    local filename = base_name .. "_specialize.lua"
    local str = 'require \'' .. base_name .. '_specialize\''
    assert(plpath.isfile(filename))
    loadstring(str)()
    local stat_chk = base_name .. '_specialize'
    local stat_chk_fn = assert(_G[stat_chk], 
    "function not found " .. stat_chk)
    for i, fldtype in ipairs(qtypes) do 
      local status, subs, tmpl = pcall(
      stat_chk_fn, in1type, in2type, optargs)
      if ( status ) then 
        -- TODO Improve following.
        local T = dofile(tmpl)
        T.fn         = subs.fn
        T.fldtype    = subs.fldtype
        T.c_code_for_operator = subs.c_code_for_operator
        gen_doth(T.fn, T, incdir)
        gen_dotc(T.fn, T, srcdir)
        print("Produced ", T.fn)
      end
    end
  end
