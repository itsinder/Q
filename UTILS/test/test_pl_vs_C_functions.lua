local plpath        = require 'pl.path'
local plfile        = require 'pl.file'
local qc            = require 'Q/UTILS/lua/q_core'

local path_to_here = os.getenv("Q_SRC_ROOT") .. "/UTILS/test/"
assert(plpath.isdir(path_to_here))

local tests = {}

tests.t1 = function()
  
  local pl_isfile_val = plpath.isfile(path_to_here .. "test_utils.lua")
  local qc_isfile_val = qc["file_exists"](path_to_here .. "test_utils.lua")
  assert(pl_isfile_val == qc_isfile_val)

  local pl_size = plpath.getsize(path_to_here .. "test_utils.lua")
  local qc_size = qc["get_file_size"](path_to_here .. "test_utils.lua")
  assert( pl_size == tonumber(qc_size))

  local pl_del_val = plfile.delete("tests1.txt")
  assert(pl_del_val == nil)
  local qc_del_val = qc["delete_file"]("tests2.txt")
  assert(qc_del_val == false)
  
end

return tests