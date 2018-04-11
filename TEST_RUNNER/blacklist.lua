-- This file contains list of tests which you want to exclude
-- Provide relative path from q_src_root along with the test-case file name

local blacklist_files = {
  "TEST_RUNNER/test_test1.lua",
  "TEST_RUNNER/test_test2.lua",
  "TEST_RUNNER/test_run_func.lua",
  "TESTS/test_log_reg_1.lua",
  "TESTS/test_log_reg_2.lua",
  "ML/LOGISTIC_REGRESSION/test/test_simple.lua",
  -- below is not a test
  "UTILS/lua/test_init.lua",
  -- below is not a test
  "UTILS/lua/test_utils.lua",
  -- Mail subject : List of failure tests in dev branch
  -- Let’s move the others into the black list
  "OPERATORS/APPROX/FREQUENT/test/test_approx_frequent.lua",
  "ML/LOGISTIC_REGRESSION/test/test_mnist.lua",
  "ML/LOGISTIC_REGRESSION/test/test_logistic_regression.lua",
  "OPERATORS/PCA/test/test_pca.lua",
  "ML/LOGISTIC_REGRESSION/test/test_really_simple.lua",
  "OPERATORS/MM/test/test_mv_mul.lua",
  "OPERATORS/PCA/test/test_eigen.lua",
  "OPERATORS/APPROX/QUANTILE/test/test_aq.lua",
  -- blacklisting this testcase to exclude it from the failure count
  -- F1F2OPF3 vvand, vvor, vvandnot issue is known and has been assigned to Ramesh
  "OPERATORS/F1F2OPF3/test/test_f1f2opf3_logical_op.lua",

}

return blacklist_files
