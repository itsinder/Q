-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local qconsts = require 'Q/UTILS/lua/q_consts'
local utils = require 'Q/UTILS/lua/utils'
local plpath  = require 'pl.path'
local plfile  = require 'pl.file'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/OPERATORS/UNIQUE/test/"
assert(plpath.isdir(path_to_here))

local chunk_size = qconsts.chunk_size

-- validating unique operator to return unique values from input vector
-- FUNCTIONAL
-- where num_elements are less than chunk_size
local tests = {}
tests.t1 = function ()
  local src_lnk_tbl = {10,10,10,10,20,20,30}
  local src_fld_tbl = {1,2,2,1,3,2,1}
  local dst_lnk_tbl = {10,20,30}
  local src_lnk = Q.mk_col(src_lnk_tbl, "I8")
  local src_fld = Q.mk_col(src_fld_tbl, "I8")
  local dst_lnk = Q.mk_col(dst_lnk_tbl, "I8")
  local c = Q.join(src_lnk, src_fld, dst_lnk, "sum")
  c:eval()
  Q.print_csv(c)

--  for i = 1, c:length() do
--    local value = c_to_txt(c, i)
--    assert(value == out_table[i])

--    value = c_to_txt(d, i)
--    assert(value == cnt_table[i])
--  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t1 succeeded")
end
return tests
