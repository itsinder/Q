-- FUNCTIONAL
require 'Q/UTILS/lua/strict'

local l_Vector = require 'Q/RUNTIME/test/lVector_test/l_Vector'
local testsuite_lVector = require 'Q/RUNTIME/test/lVector_test/testsuite_l_Vector'
local suite_runner = require 'Q/UTILS/lua/suite_runner'

local status, failures = pcall(suite_runner, testsuite_lVector, l_Vector, nil)

--assert(#failures == 0, "Some Tests Failed \n" .. failures)
--print("Tests passed.")
print("Failed Testcases are ...")
print(failures)

require('Q/UTILS/lua/cleanup')()
os.exit()