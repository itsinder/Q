  local gen_code = require 'gen_code'
  local plpath = require "pl.path"
  loadfile 'globals.lua'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"

  local operator_file = assert(arg[1])
  assert(plpath.isfile(operator_file))
  local operators = dofile(operator_file)
  local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

  for i, operator in ipairs(operators) do
    local sp_fn = require (operator .. '_specialize')

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
            T.out_qtype  = subs.out_qtype
            T.out_ctype  = subs.out_ctype
            T.argstype   = subs.argstype
            T.c_code_for_operator = subs.c_code_for_operator
            gen_code.doth(T.fn, T, incdir)
            gen_code.dotc(T.fn, T, srcdir)
            print("Produced ", T.fn)
          end
        end
    end
  end
