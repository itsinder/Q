require 'Q/UTILS/lua/strict'
local qc = require 'Q/UTILS/lua/q_core'
local ffi = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'

local fns_name = "simple_ainb_I4_I4"
local chunk_count = 0
-- generator validator function
local function my_magic_function(aptr, alen, bptr, blen, cbuf)
  print("Validating Generator Function, Length: ", alen)
  aptr = ffi.cast("int32_t *", aptr)
  local diff = chunk_count * qconsts.chunk_size
  for i = 1, alen do
    assert(aptr[i-1] == (i + diff), "Value Mismatch, Actual: " .. aptr[i-1] .. ", Expected: " .. (i + diff))
  end
  chunk_count = chunk_count + 1
  return 0
end

-- set custom validation function
qc[fns_name] = my_magic_function

local tests = {}
tests.t1 = function()
  local Q = require 'Q'
  local b = Q.mk_col({-2, 0, 2, 4 }, "I4")
  --local a = Q.mk_col({-2, -2, -1, -1, 0, 1, 1, 2, 2, 3, 3}, "I4")

  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 65540} )

  local c = Q.ainb(a, b)
  c:eval()

  --Q.print_csv(c, nil, "")
end

return tests
