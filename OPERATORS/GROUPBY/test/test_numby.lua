local Q = require 'Q'
local ffi = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'

hdr = [[
extern int numby_I4(
    int32_t *X, /* [nX] */
    uint32_t nX,
    int64_t  *Z, /* [nZ] */
    uint32_t nZ,
    bool is_safe
    );
]]
ffi.cdef(hdr)

local tests = {}

tests.t1 = function()
  local len = 2*qconsts.chunk_size + 1
  local period = 3
  local a = Q.period({ len = len, start = 0, by = 1, period = period, qtype = "I4"})
  Q.numby = require 'Q/OPERATORS/GROUPBY/lua/expander_numby'
  local rslt = Q.numby(a, period)
  Q.print_csv(rslt)
  print("Test t1 completed")
end

tests.t2 = function()
  -- Elements equal to chunk_size
  local len = qconsts.chunk_size
  local period = 3
  local a = Q.period({ len = len, start = 0, by = 1, period = period, qtype = "I4"})
  Q.numby = require 'Q/OPERATORS/GROUPBY/lua/expander_numby'
  local rslt = Q.numby(a, period)
  Q.print_csv(rslt)
  print("Test t2 completed")
end

return tests
