local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"

-- assert(#arg == 2, "Usage is lua ", arg[0], " <file1> <file2> ")
-- file1 = arg[1]
-- file2 = arg[2]
function diff(
  file1, 
  file2
  )
  io.input(file1)
  local s1 = io.read("*all")
  io.close()

  io.input(file2)
  local s2 = io.read("*all")
  io.close()

  if ( s1 == s2 ) then return true else return false end 
end
-- x = diff("dbl_out1.csv", "_dbl_out1.csv")
-- print(x)
