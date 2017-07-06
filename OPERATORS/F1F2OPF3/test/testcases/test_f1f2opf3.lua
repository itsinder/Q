-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local f1f2opf3 = require 'Q/OPERATORS/F1F2OPF3/test/testcases/f1f2opf3'
local testsuite_f1f2opf3 = require 'Q/OPERATORS/F1F2OPF3/test/testcases/testsuite_f1f2opf3'


local suite_runner = require 'Q/UTILS/lua/suite_runner'

local status, failures = pcall(suite_runner, testsuite_f1f2opf3, f1f2opf3, nil)

assert(#failures == 0, "Some Tests Failed \n" .. failures)
print("Tests passed.")

require('Q/UTILS/lua/cleanup')()
os.exit()
