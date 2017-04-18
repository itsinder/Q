#!/usr/bin/env lua

  local rootdir = os.getenv("Q_SRC_ROOT")
  assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
  local gen_code = require("gen_code")
  local plpath = require "pl.path"
  dofile '../../../UTILS/lua/globals.lua'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"

  local operator_file = assert(arg[1])
  assert(plpath.isfile(operator_file))
  local operators = dofile(operator_file)
  local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

  for i, operator in ipairs(operators) do
    local sp_fn_name = string.format(" require '%s_specialize'", operator)
    local sp_fn = nil
    if ( operator == "vsadd" ) then 
      sp_fn = require 'vsadd_specialize'
    elseif ( operator == "vssub" ) then 
      sp_fn = require 'vssub_specialize'
    elseif ( operator == "vsmul" ) then 
      sp_fn = require 'vsmul_specialize'
    elseif ( operator == "vsdiv" ) then 
      sp_fn = require 'vsdiv_specialize'
    elseif ( operator == "vsrem" ) then 
      sp_fn = require 'vsrem_specialize'
    else
      assert(nil, "Bad operator")
    end
    for i, fldtype in ipairs(qtypes) do 
      local status, subs, tmpl = pcall(sp_fn, fldtype)
      if ( status ) then 
        -- TODO Improve following.
        local T = dofile(tmpl)
        T.fn         = subs.fn
        T.fldtype    = subs.fldtype
        T.c_code_for_operator = subs.c_code_for_operator
        T.comparison = subs.comparison
        T.comp1 = subs.comp1
        T.comp2 = subs.comp2
        T.combiner = subs.combiner
        gen_code.doth(T.fn, T, incdir)
        gen_code.dotc(T.fn, T, srcdir)
        print("Produced ", T.fn)
      end
    end
  end
