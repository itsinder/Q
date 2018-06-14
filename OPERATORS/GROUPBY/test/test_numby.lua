local Q = require 'Q'
local ffi = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
local Scalar = require 'libsclr'
require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local len = 2*qconsts.chunk_size + 1
  local period = 3
  local a = Q.period({ len = len, start = 0, by = 1, period = period, qtype = "I4"})
  local rslt = Q.numby(a, period)
  -- Q.print_csv(rslt)
  print("Test t1 completed")
end

tests.t2 = function()
  local len = 2*qconsts.chunk_size + 1
  local lb = 0
  local ub = 4
  local range = ub - lb + 1
  local a = Q.rand({ len = len, lb = 0, ub = 4, qtype = "I4"})
  Q.numby = require 'Q/OPERATORS/GROUPBY/lua/expander_numby'
  local rslt = Q.numby(a, range)
  assert(type(rslt) == "lVector")
  -- Q.print_csv(rslt)
  rslt:eval()
  for i = lb, ub do 
    local n1, n2 = Q.sum(Q.vseq(a, Scalar.new(i, "I4"))):eval()
    assert(n1 == rslt:get_one(i))
  end
  print("Test t2 completed")
end


tests.t3 = function()
  -- Elements equal to chunk_size
  local len = qconsts.chunk_size
  local period = 3
  local a = Q.period({ len = len, start = 0, by = 1, period = period, qtype = "I4"})
  local rslt = Q.numby(a, period)
  Q.print_csv(rslt)
  print("Test t3 completed")
end


return tests
