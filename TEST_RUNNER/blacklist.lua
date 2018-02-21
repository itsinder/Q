-- This file contains list of tests which you want to exclude
-- Provide relative path from q_src_root along with the test-case file name

local blacklist_files = {
  "TEST_RUNNER/test_test1.lua",
  "TEST_RUNNER/test_test2.lua",
  "TEST_RUNNER/test_run_func.lua",
  "TESTS/test_log_reg_1.lua",
  "TESTS/test_log_reg_2.lua"
}

return blacklist_files
