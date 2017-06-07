#!/usr/bin/env lua
require 'Q/UTILS/lua/globals'
local gen_code = require 'Q/UTILS/lua/gen_code'
local plpath = require "pl.path"
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"

local operator_file = assert(arg[1])
assert(plpath.isfile(operator_file))
local operators = dofile(operator_file)

-- local T = dofile 'const.tmpl'

-- local args = {}
qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }

-- local const_specialize = require 'const_specialize'
-- args.val = 123 -- just to test const_specialize
-- args.len = 100 -- just to test const_specialize

local num_produced = 0
for i, operator in ipairs(operators) do
  local sp_fn = assert(require(operator .. "_specialize"))
  for i, qtype in ipairs(qtypes) do 
    -- args.qtype = qtype
    status, subs, tmpl = pcall(sp_fn, qtype)
    assert(status, subs)
    gen_code.doth(subs, tmpl, incdir)
    gen_code.dotc(subs, tmpl, srcdir)
    print("produced ", subs.fn)
  end
end

assert(num_produced > 0)
