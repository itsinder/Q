-- FUNCTIONAL
local Q = require 'Q'
local Scalar = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
require('Q/UTILS/lua/cleanup')()
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function()
  local val_qtype = "I4"
  local cnt_qtype = "I8"
  -- local len = qconsts.chunk_size * 2 + 17
  local len = 17
  local c1 = Q.seq({start = 1, by = 1, len = len, qtype = val_qtype })
  local c2 = Q.cum_cnt(c1, nil, { cnt_qtype = cnt_qtype } ):eval()
  local exp_c2 = Q.const({ val = 1, qtype = cnt_qtype, len=len})
  local n1, n2 = Q.sum(Q.vveq(c2, exp_c2)):eval()
  assert(n1 == n2)
  assert(c2:fldtype() == cnt_qtype)
  print("Test t1 succeeded")
end
tests.t2 = function()
  local val_qtype = "I4"
  local cnt_qtype = "I2"
  local c1 = Q.mk_col({1, 1, 2, 2, 3, 3, 4, 4, 5}, val_qtype):eval()
  local exp_c2 = Q.mk_col({1, 2, 1, 2, 1, 2, 1, 2, 1}, cnt_qtype):eval()
  local c2 = Q.cum_cnt(c1, nil, { cnt_qtype = cnt_qtype } ):eval()
  assert(c2:fldtype() == cnt_qtype)
  -- Q.print_csv({c1, c2})
  local n1, n2 = Q.sum(Q.vveq(c2, exp_c2)):eval()
  assert(n1 == n2)
  print("Test t2 succeeded")
end
return tests
