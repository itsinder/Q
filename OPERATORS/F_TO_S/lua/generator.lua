  local plfile = require 'pl.file'
  loadfile 'globals.lua'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  local gen_code = require("gen_code")
  plfile.delete("_qfns_f_to_s.lua")

  local operator_file = assert(arg[1])
  assert(plfile.access_time(operator_file))
  local operators = dofile(operator_file)
  

  local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

  args = nil -- not being used just yet
  for i, operator in ipairs(operators) do
    local sp_fn_name = string.format(" require '%s_specialize'", operator)
    local sp_fn = nil
    if ( operator == "min" ) then 
      sp_fn = require 'min_specialize'
    elseif ( operator == "sum" ) then 
      sp_fn = require 'sum_specialize'
    elseif ( operator == "max" ) then 
      sp_fn = require 'max_specialize'
    elseif ( operator == "sum_sqr" ) then 
      sp_fn = require 'sum_sqr_specialize'
    else
      assert(nil, "Bad operator")
    end
    for i, intype in ipairs(types) do 
      local status, subs, tmpl = pcall(sp_fn, intype)
      if ( status ) then 
        assert(type(subs) == "table")
        assert(type(tmpl) == "string")
        -- TODO Improve following.
        local T = dofile(tmpl)
        T.fn           = subs.fn
        T.ctype        = subs.ctype
        T.reducer      = subs.reducer
        T.t_reducer    = subs.t_reducer
        T.qtype        = subs.qtype
        T.op           = subs.op
        T.reduce_ctype = subs.reduce_ctype
        T.init_val     = subs.init_val     
        gen_code.doth(T.fn, T, incdir)
        gen_code.dotc(T.fn, T, srcdir)
        print("Generated ", T.fn)
      else
        print("Failed ", intype, subs)
      end
    end
  end
