local Q = require 'Q'
local Scalar = require 'libsclr'

local tests = {}
local qconsts = require 'Q/UTILS/lua/q_consts'

tests.t1 = function()
  -- Simple test to check save() & restore() functionality  
  col1 = Q.mk_col({10,20,30,40,50}, "I4")
  Q.save("/tmp/saving_it.lua")

  -- nullifying col1 before restoring
  col1 = nil

  local status, ret = pcall(Q.restore, "/tmp/saving_it.lua")
  assert(status, ret)
  assert(col1:num_elements() == 5)
  print("Successfully executed test t1")
end

tests.t2 = function()
  -- Test to check whether default_meta_file from qconsts is used to save the metadata
  -- assuming Q_METADATA_FILE env is not set
  col1 = Q.mk_col({10,20,30,40,50}, "I4")
  -- Call save() without argument
  local filename = Q.save()
  local default_meta_file = string.gsub(qconsts.default_meta_file, "$HOME", os.getenv("HOME"))
  assert(filename == default_meta_file)
  print("Successfully executed test t2")
end

tests.t3 = function()
  -- Test to validate if Q_METADATA_FILE env is set, it is been used to save metadata
  local posix = require 'posix.stdlib'
  col1 = Q.mk_col({10,20,30,40,50}, "I4")
  -- Call save() without argument
  posix.setenv('Q_METADATA_FILE', '/tmp/saved.meta')
  local filename = Q.save()
  assert(filename == '/tmp/saved.meta')
  print("Successfully executed test t3")
end

tests.t4 = function()
  -- Test to check whether aux metadata is restored after calling restore()
  col1 = Q.mk_col({10,20,30,40,50}, "I4")
  col1:set_meta("key1", "value1")
  Q.save("/tmp/saving_it.lua")
  
  -- nullifying col1 before restoring
  col1 = nil

  -- restore operation
  local status, ret = pcall(Q.restore, "/tmp/saving_it.lua")
  assert(status, ret)
  assert(col1:meta().aux.key1)
  assert(col1:meta().aux.key1 == "value1")
  assert(col1:meta().base.is_persist == true)
  print("Successfully executed test t4")
end

tests.t5 = function()
    -- JIRA QQ-160:
    -- verifying Q.save() should not try to persist global Vectors that have been marked as memo = false
    col1 = Q.seq({ start = 1, by = 1, len = 10 , qtype = "I8"})
    col1:memo(false)
    col1:eval()
    Q.save("/tmp/saving_it.lua")
end

tests.t6 = function()
  -- creating global Scalars
  sc_B1_bool = Scalar.new(true, "B1")
  sc_I1 = Scalar.new(100, "I1")
  sc_B1_num = Scalar.new(0, "B1")
  Q.save("/tmp/saving_sclrs.lua")

  -- nullifying sc before restoring
  sc_B1_bool = nil
  sc_I1 = nil
  sc_B1_num = nil

  local status, ret = pcall(Q.restore, "/tmp/saving_sclrs.lua")
  assert(status, ret)
  assert(sc_B1_bool:to_str() == "true")
  assert(sc_B1_bool:to_num() == 1)
  assert(sc_I1:to_num() == 100)
  print("Successfully executed test t6")
end

return tests


