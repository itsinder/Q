#!/usr/bin/env/lua
local gen_code = require 'Q/UTILS/lua/gen_code'
local plpath = require "pl.path"
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"

qtypes = { "I1", "I2", "I4", "I8" } -- TODO make aq work with F4 and F8

local num_produced = 0
sp_fn = assert(require("aq_specialize"))
for _, intype in ipairs(qtypes) do
  local status, subs, tmpls = pcall(sp_fn, intype)
  if ( status ) then
    assert(type(subs) == "table")
    assert(type(tmpls) == "table")
    for _, tmpl in ipairs(tmpls) do
      subs.fn = string.sub(tmpl, 1, #tmpl - 5) .. "_" .. subs.qtype
      gen_code.doth(subs, tmpl, incdir)
      gen_code.dotc(subs, tmpl, srcdir)
      print("Generated ", subs.fn)
      num_produced = num_produced + 1
    end
  else
    print("Failed ", intype, subs)
  end
end

assert(num_produced > 0)

