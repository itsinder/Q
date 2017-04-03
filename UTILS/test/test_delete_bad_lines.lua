local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"

require 'parser'
require 'delete_bad_lines'
require 'diff'

local regexs = {
  "[a-zA-Z]*",
  "[0-9]+"
}
delete_bad_lines("dbl_in1.csv", "_dbl_out1.csv", regexs)
assert(diff("dbl_out1.csv", "_dbl_out1.csv"), "Test failed")
print("Test passed")
