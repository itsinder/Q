local dbl = require 'delete_bad_lines'
local diff = require 'diff'

local regexs = {
  "[a-zA-Z]*",
  "[0-9]+"
}
dbl("dbl_in1.csv", "_dbl_out1.csv", regexs)
assert(diff("dbl_out1.csv", "_dbl_out1.csv"), "Test failed")
--===========================
local regexs = { '[0-9\-a-f]*' }
dbl("dbl_in2.csv", "_dbl_out2.csv", regexs)
assert(diff("dbl_out2.csv", "_dbl_out2.csv"), "Test failed")
--===========================
print("Test passed")
os.exit()
