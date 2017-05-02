#!/usr/bin/env lua

require 'globals'
local gen_code = require 'gen_code'
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"

local T = dofile 'const.tmpl'

local args = {}
qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }

local const_specialize = require 'const_specialize'
args.val = 123
args.len = 100
for i, qtype in ipairs(qtypes) do 
  args.qtype = qtype
  status, subs, tmpl = pcall(const_specialize, args)
  if ( not status ) then print ( subs) end
  assert(status); 
  assert(type(subs) == "table")
  -- TODOA Avoid repeated assignment frm subs to T
  T.out_ctype = subs.out_ctype
  T.out_qtype = subs.out_qtype
  fn = subs.fn
  gen_code.doth(subs.fn, T, incdir)
  gen_code.dotc(subs.fn, T, srcdir)
  print("produced ", subs.fn)
end
