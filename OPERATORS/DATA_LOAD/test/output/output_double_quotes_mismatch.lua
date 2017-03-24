-- output error message for double quote mismatch
local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
require("error_code")

return { 
  error_msg = g_err.INVALID_INDEX_ERROR
}