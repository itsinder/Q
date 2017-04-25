  local gen_code = require 'gen_code'
  local plpath = require "pl.path"
  dofile 'globals.lua'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  local dbg = require 'debugger'

  local operator_file = assert(arg[1])
  assert(plpath.isfile(operator_file))
  local operators = dofile(operator_file)
  local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

  for i, operator in ipairs(operators) do
    -- ==================
    -- TODO Fix this 
    local sp_fn_name = string.format(" require '%s_specialize'", operator)
    local sp_fn = nil
    if ( operator == "vvadd" ) then 
      sp_fn = require 'vvadd_specialize'
    elseif ( operator == "vvsub" ) then 
      sp_fn = require 'vvsub_specialize'
    elseif ( operator == "vvmul" ) then 
      sp_fn = require 'vvmul_specialize'
    elseif ( operator == "vvdiv" ) then 
      sp_fn = require 'vvdiv_specialize'
    elseif ( operator == "vvrem" ) then 
      sp_fn = require 'vvrem_specialize'
    else
      assert(nil, "Bad operator")
    end
    for i, in1type in ipairs(types) do 
      for j, in2type in ipairs(types) do 
          local status, subs, tmpl = pcall(
          sp_fn, in1type, in2type, optargs)
          if ( status ) then 
            assert(type(subs) == "table")
            assert(type(tmpl) == "string")
            -- TODO Improve following.
            local T = dofile(tmpl)
            T.fn         = subs.fn
            T.includes   = subs.includes
            T.in1type    = subs.in1type
            T.in2type    = subs.in2type
            T.outtype    = subs.outtype
            T.out_c_type = subs.out_c_type
            T.argstype   = subs.argstype
            T.c_code_for_operator = subs.c_code_for_operator
            gen_code.doth(T.fn, T, incdir)
            gen_code.dotc(T.fn, T, srcdir)
            print("Produced ", T.fn)
          end
        end
    end
  end
