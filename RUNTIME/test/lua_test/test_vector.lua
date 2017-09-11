-- FUNCTIONAL
require 'Q/UTILS/lua/strict'

local vector = require 'Q/RUNTIME/test/lua_test/vector'
local testsuite_vector = require 'Q/RUNTIME/test/lua_test/testsuite_vector'
local suite_runner = require 'Q/UTILS/lua/suite_runner'

local status, failures = pcall(suite_runner, testsuite_vector, vector, nil)

--assert(#failures == 0, "Some Tests Failed \n" .. failures)
--print("Tests passed.")
print(status)
print(failures)

require('Q/UTILS/lua/cleanup')()
os.exit()
