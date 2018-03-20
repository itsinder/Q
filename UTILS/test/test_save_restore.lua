local Q = require 'Q'

local tests = {}
local qconsts = require 'Q/UTILS/lua/q_consts'

tests.t1 = function()
  
  local col1 = Q.mk_col({10,20,30,40,50}, "I4")

  Q.save("/tmp/saving_it.lua")
  local status, ret = pcall(Q.restore, "/tmp/saving_it.lua")
  
  assert(status, ret)
  assert(col1:num_elements() == 5)
  print("Successfully executed test t1")
end

tests.t2 = function()
  local col1 = Q.mk_col({10,20,30,40,50}, "I4")
  -- Call save() without argument, assuming Q_METADATA_FILE env is not set
  local filename = Q.save()
  local default_meta_file = string.gsub(qconsts.default_meta_file, "$HOME", os.getenv("HOME"))
  assert(filename == default_meta_file)
  print("Successfully executed test t2")
end

tests.t3 = function()
  local posix = require 'posix.stdlib'
  local col1 = Q.mk_col({10,20,30,40,50}, "I4")
  -- Call save() without argument, set Q_METADATA_FILE env variable
  posix.setenv('Q_METADATA_FILE', '/tmp/saved.meta')
  local filename = Q.save()
  assert(filename == '/tmp/saved.meta')
  print("Successfully executed test t3")
end

return tests


