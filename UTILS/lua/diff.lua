local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")

-- assert(#arg == 2, "Usage is lua ", arg[0], " <file1> <file2> ")
-- file1 = arg[1]
-- file2 = arg[2]
return function (
  file1, 
  file2
  )
  local f1 = io.open(file1, "r")
  local s1 = f1:read("*a")
  f1:close()
  local f2 = io.open(file2, "r")
  local s2 = f2:read("*a")
  f2:close()

  if ( s1 == s2 ) then return true else return false end 
end
-- x = diff("dbl_out1.csv", "_dbl_out1.csv")
-- print(x)
