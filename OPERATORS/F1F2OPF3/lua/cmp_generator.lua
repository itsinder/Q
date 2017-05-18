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
    local sp_fn = require (operator .. '_specialize')

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
