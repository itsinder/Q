--- BEGIN SETUP
--print(package.path)
package.path = package.path .. ';/home/srinath/Ramesh/Q/Q2/code/lua/?.lua;/home/srinath/Ramesh/Q/UTILS/lua/?.lua;/home/srinath/Ramesh/Q/OPERATORS/MK_COL/lua/?.lua'

-- for test data
package.path = package.path .. ';/home/srinath/Ramesh/Q/OPERATORS/PERMUTE/test/?.lua'
--- END SETUP
ffi = require 'ffi'
package.terrapath = package.terrapath .. ";/home/srinath/Ramesh/Q/OPERATORS/PERMUTE/terra/?.t"
--print(package.path)
require 'globals'
require 'terra_globals'
require 'error_code'
require 'permute'

local Column = require 'Column'

local testdata = require 'testdata_permute'
local testrunner = require 'test_runner'

testrunner(testdata, permute)
print("Tests passed.")