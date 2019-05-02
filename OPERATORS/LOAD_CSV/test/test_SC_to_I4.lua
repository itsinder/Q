-- FUNCTIONAL
local Q = require 'Q'
local plfile = require 'pl.file'
require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function ()
  local in_col = Q.mk_col({ "abc", "def", "ghi", "xxx"}, "SC"):set_name("incol")
  local dict = { }
  dict["abc"] = 1
  dict["def"] = 2
  dict["ghi"] = 3
  dict["jkl"] = 4
  local filename = "/tmp/_XXXXX"
  local qtypes = { "I1", "I2", "I4", "I8"}
  for _, qtype in pairs(qtypes) do 
    local optargs = { qtype = qtype }
    local outv = Q.SC_to_I4(in_col, dict, optargs):eval()
    local chk_outv = Q.mk_col({1,2,3,0}, qtype)
    assert(chk_outv:fldtype() == qtype)
    local n1, n2 = Q.sum(Q.vveq(outv, chk_outv)):eval()
    assert(n1 == n2)
  end

end
return tests
