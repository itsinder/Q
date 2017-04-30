#!/usr/bin/env lua
  local gen_code =  require("gen_code")
  local pl = require 'pl'
  loadfile 'globals.lua'

  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  local operators = dofile 'cmp_operators.lua' 
  local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

  args = nil -- not being used just yet
  for i, operator in ipairs(operators) do
    local sp_fn_name = string.format(" require '%s_specialize'", operator)
    local sp_fn = nil
    if ( operator == "vveq" ) then 
      sp_fn = require 'vveq_specialize'
    elseif ( operator == "vvneq" ) then 
      sp_fn = require 'vvneq_specialize'
    elseif ( operator == "vvleq" ) then 
      sp_fn = require 'vvleq_specialize'
    elseif ( operator == "vvgeq" ) then 
      sp_fn = require 'vvgeq_specialize'
    elseif ( operator == "vvlt" ) then 
      sp_fn = require 'vvlt_specialize'
    elseif ( operator == "vvgt" ) then 
      sp_fn = require 'vvgt_specialize'
    else
      assert(nil, "Bad operator")
    end
    for i, in1type in ipairs(types) do 
      for j, in2type in ipairs(types) do 
        local status, subs, tmpl = pcall(sp_fn, in1type, in2type)
        if ( status ) then 
          -- TODO Improve following.
          local T = dofile(tmpl)
          T.fn         = subs.fn
          T.in1type    = subs.in1type
          T.in2type    = subs.in2type
          T.out_ctype = subs.out_ctype
          T.comparison = subs.comparison
          gen_code.doth(subs.fn, T, incdir)
          gen_code.dotc(subs.fn, T, srcdir)
          print("Produced ", T.fn)
        end
      end
    end
  end
