  local rootdir = os.getenv("Q_SRC_ROOT")
  assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
  local gen_code = require("gen_code")
  local dbg = require 'debugger'
  local plpath = require 'pl.path'
  dofile '../../../UTILS/lua/globals.lua'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  local operator_file = assert(arg[1])
  assert(plpath.isfile(operator_file))
  local operators = dofile(operator_file)
  --==================================================
  local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  for i, operator in ipairs(operators) do
    -- ==================
    -- sp_fn = specializer function 
    local sp_fn_name = operator .. "_specialize"
    local str = 'local sp_fn = require "' .. sp_fn_name .. '"'
    local sp_fn = require 'concat_specialize'
    for i, in1type in ipairs(types) do 
      for j, in2type in ipairs(types) do 
        for k, outtype in ipairs(types) do 
          local optargs = {}
          optargs.outtype = outtype
          -- print("Lua premature", stat_chk); os.exit()
          local status, subs, tmpl = pcall(
          sp_fn, in1type, in2type, optargs)
          if ( status) then
            -- TODO Improve following.
            local T = loadstring(tmpl)()
            T.fn       = subs.fn
            T.includes = subs.includes
            T.in1type  = subs.in1type
            T.in2type  = subs.in2type
            T.outtype  = subs.outtype
            T.out_c_type  = subs.out_c_type
            T.argstype = subs.argstype
            T.c_code_for_operator = subs.c_code_for_operator
            gen_code.doth(T.fn, T, incdir)
            gen_code.dotc(T.fn, T, srcdir)
            print("Produced ", T.fn)
          end
        end
      end
    end
  end
