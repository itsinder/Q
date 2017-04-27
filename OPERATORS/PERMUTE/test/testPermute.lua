--- BEGIN SETUP
--print(package.path)
package.path = package.path .. ';/home/srinath/Ramesh/Q/Q2/code/lua/?.lua;/home/srinath/Ramesh/Q/UTILS/lua/?.lua;/home/srinath/Ramesh/Q/OPERATORS/MK_COL/lua/?.lua'

-- for test data
package.path = package.path .. ';/home/srinath/Ramesh/Q/OPERATORS/PERMUTE/test/?.lua'
--- END SETUP

package.terrapath = package.terrapath .. ";/home/srinath/Ramesh/Q/OPERATORS/PERMUTE/terra/?.t"
--print(package.path)
require 'globals'
require 'terra_globals'
require 'error_code'
require 'permute' 

local suite = require 'testdata_permute'
local testrunner = require 'test_runner'

local failures = testrunner(suite, permute)
if (#failures > 0) then
  print ("Failed tests: " .. tostring(failures))
else
  print("Tests passed.")
end