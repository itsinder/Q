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

-- test for num_elements > chunk_size
tests.t2 = function ()
  local src_lnk_tbl = {}
  local src_fld_tbl = {}
  for i = 1, qconsts.chunk_size do
    if i%2 == 0 then
      src_lnk_tbl[#src_lnk_tbl+1] = 10
      src_fld_tbl[#src_fld_tbl+1] = 1
    else
      src_lnk_tbl[#src_lnk_tbl+1] = 20
      src_fld_tbl[#src_fld_tbl+1] = 2
    end
  end
  for i = qconsts.chunk_size+1, (qconsts.chunk_size + (qconsts.chunk_size/2)) do
    if i%2 == 0 then
      src_lnk_tbl[#src_lnk_tbl+1] = 20
      src_fld_tbl[#src_fld_tbl+1] = 2
    else
      src_lnk_tbl[#src_lnk_tbl+1] = 30
      src_fld_tbl[#src_fld_tbl+1] = 3
    end
  end
  local dst_lnk_tbl = {10,20}
  local src_lnk = Q.mk_col(src_lnk_tbl, "I4")
  local src_fld = Q.mk_col(src_fld_tbl, "I4")
  local dst_lnk = Q.mk_col(dst_lnk_tbl, "I4")
  Q.sort(src_lnk, "asc"):eval()
  Q.sort(src_fld, "asc"):eval()
  Q.sort(dst_lnk, "asc"):eval()
  local c = Q.join(src_lnk, src_fld, dst_lnk, "max_idx")
  c:eval()
  Q.print_csv(c)
  print(c:fldtype())
  print(c:length())
  local unq, cnt = Q.unique(src_lnk)
  unq:eval()
  Q.print_csv({unq, cnt})
--  for i = 1, c:length() do
--    local value = c_to_txt(c, i)
--    assert(value == out_table[i])

--    value = c_to_txt(d, i)
--    assert(value == cnt_table[i])
--  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t2 succeeded")
end


tests.t3 = function ()
  local src_lnk_tbl = {10,10,10,10,20,20,30}
  local src_fld_tbl = {1,21,12,11,3,-1,23}
  local dst_lnk_tbl = {10,20,30,40}
  local src_lnk = Q.mk_col(src_lnk_tbl, "I1")
  local src_fld = Q.mk_col(src_fld_tbl, "I1")
  local dst_lnk = Q.mk_col(dst_lnk_tbl, "I1")
  local c = Q.join(src_lnk, src_fld, dst_lnk, "any")
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
  print("Test t3 succeeded")
end

tests.t4 = function ()
  local src_lnk_tbl = {10,20,30,50,60}
  local src_fld_tbl = {1,21,12,7,9}
  local dst_lnk_tbl = {10,20,30,40}
  local src_lnk = Q.mk_col(src_lnk_tbl, "I2")
  local src_fld = Q.mk_col(src_fld_tbl, "I1")
  local dst_lnk = Q.mk_col(dst_lnk_tbl, "I2")
  local c = Q.join(src_lnk, src_fld, dst_lnk, "any")
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
  print("Test t4 succeeded")
end



return tests
