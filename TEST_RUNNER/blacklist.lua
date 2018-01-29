-- This file contains list of tests which you want to exclude
-- Provide absolute path from q_src_root along with the test-case file name

local blacklist_files = {
  "test_foo.lua",
  "TESTS/test_log_reg_1.lua",
  "TESTS/test_log_reg_2.lua"
}

return blacklist_files
