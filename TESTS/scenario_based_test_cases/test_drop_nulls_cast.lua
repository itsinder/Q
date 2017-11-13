-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local lVector = require 'Q/RUNTIME/lua/lVector'
Scalar = require 'libsclr'

local tests = {}
tests.t1 = function ()

  -- Create vector 'a' with Q.rand or by Q.seq
  local blen = 8 -- must be a multiple of 8
  local alen = blen * 32 -- 32 bits in an I4 integer
  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = alen} )
  -- Create binary vector b through Q.rand
  local b = Q.rand( { lb = 100, ub = 200, qtype = "I4", len = blen } )
  -- b must be eval'd before it can be cast
  local status = pcall(Q.cast, b, "B1")
  assert(not status)
  assert(b:eval())
  local b1 = Q.cast(b, "B1"):set_name("b1")
  local s2 = 10 - Q.sum(b1):eval():to_num()
  local sval = Scalar.new("10", "I4")
  -- TODO P1 DISCUSS WITH INDRAJEET status = pcall(lVector.make_nulls(a, b))
  -- TODO P1 DISCUSS WITH INDRAJEET assert(not status)
  a:eval()
  a:make_nulls(b)
  local c = Q.drop_nulls(a, sval)
  assert(Q.sum(c):eval():to_num() == 76)
  print("Succeeded in test drop nulls cast t1")
end
  --=======================================
return tests


