  local gen_code = require("gen_code")
  local plpath = require 'pl.path'
  loadfile 'globals.lua'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  local operator_file = assert(arg[1])
  assert(plpath.isfile(operator_file))
  local operators = assert(dofile(operator_file))
  local types = { 'B1' }
  for i, operator in ipairs(operators) do
    -- TODO Fix this 
    local sp_fn_name = string.format(" require '%s_specialize'", operator)
    local sp_fn = nil
    if ( operator == "vvand" ) then 
      sp_fn = require 'vvand_specialize'
    elseif ( operator == "vvor" ) then 
      sp_fn = require 'vvor_specialize'
    elseif ( operator == "vvxor" ) then 
      sp_fn = require 'vvxor_specialize'
    elseif ( operator == "vvandnot" ) then 
      sp_fn = require 'vvandnot_specialize'
    else
      assert(nil, "Bad operator")
    end
    -- ==================
    for i, in1type in ipairs(types) do 
      for j, in2type in ipairs(types) do 
        local status, subs, tmpl = pcall(sp_fn, in1type, in2type)
        if ( status ) then 
          gen_code.doth(subs, tmpl, incdir)
          gen_code.dotc(subs, tmpl, srcdir)
          print("Produced ", subs.fn)
        end
      end
    end
  end
