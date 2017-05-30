#!/usr/bin/env lua

require 'UTILS/lua/globals'
incdir = "../gen_inc/"
srcdir = "../gen_src/"
local gen_code = require 'UTILS/lua/gen_code'
local tmpl = dofile 'qsort.tmpl'

order = { 'asc', 'dsc' }
qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }

local spfn = require 'sort_specialize'
for i, o in ipairs(order) do 
  for k, f in ipairs(qtypes) do 
    status, subs, tmpl = pcall(spfn, f, o)
    if ( not status ) then print(subs) end
    assert(status)
    assert(type(subs) == "table")
    gen_code.doth(subs, tmpl, incdir)
    gen_code.dotc(subs, tmpl, srcdir)
    print("Produced ", subs.fn)
  end
end
