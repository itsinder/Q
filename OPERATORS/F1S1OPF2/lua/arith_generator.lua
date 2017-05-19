#!/usr/bin/env lua
  local gen_code = require("gen_code")
  local plpath = require "pl.path"
  loadfile 'globals.lua'
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
    elseif ( operator == "vsand" ) then 
      sp_fn = require 'vsand_specialize'
    elseif ( operator == "vsor" ) then 
      sp_fn = require 'vsor_specialize'
    elseif ( operator == "vsxor" ) then 
      sp_fn = require 'vsxor_specialize'
    elseif ( operator == "vseq" ) then 
      sp_fn = require 'vseq_specialize'
    elseif ( operator == "vsneq" ) then 
      sp_fn = require 'vsneq_specialize'
    elseif ( operator == "vsleq" ) then 
      sp_fn = require 'vsleq_specialize'
    elseif ( operator == "vsgeq" ) then 
      sp_fn = require 'vsgeq_specialize'
    elseif ( operator == "vsgt" ) then 
      sp_fn = require 'vsgt_specialize'
    elseif ( operator == "vslt" ) then 
      sp_fn = require 'vslt_specialize'
    elseif ( operator == "vsltorgt" ) then 
      sp_fn = require 'vsltorgt_specialize'
    elseif ( operator == "vsleqorgeq" ) then 
      sp_fn = require 'vsleqorgeq_specialize'
    elseif ( operator == "vsgeqandleq" ) then 
      sp_fn = require 'vsgeqandleq_specialize'
    elseif ( operator == "vsgtandlt" ) then 
      sp_fn = require 'vsgtandlt_specialize'
    else
      assert(nil, "Bad operator " .. operator)
    end
    for i, fldtype in ipairs(qtypes) do 
      for j, scalar_type in ipairs(qtypes) do 
        local status, subs, tmpl = pcall(sp_fn, fldtype, nil, scalar_type)
        if ( status ) then 
          assert(type(subs) == "table")
          assert(type(tmpl) == "string")
          print(subs)
          gen_code.doth(subs,tmpl, incdir)
          gen_code.dotc(subs, tmpl, srcdir)
          print("Produced ", subs.fn)
        end
      end
    end
  end
