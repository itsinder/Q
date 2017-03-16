  package.path = package.path.. ";../../../UTILS/lua/?.lua"
-- local plutils = require 'pl.util'
-- local plpath = require 'pl.path'
local dbg = require 'debugger'
local plfile = require 'pl.file'
local pldir = require 'pl.dir'
local root = "/home/subramon/WORK/Q/"
local pattern = "*.c"
local destdir = "/tmp/LUA/"
function recursive_descent(root)
  local F = pldir.getfiles(root, pattern)
  if ( ( F )  and ( #F > 0 ) ) then 
    for index, v in ipairs(F) do
      if ( string.find(v, "\/_") ) then 
        print("Copying ", v, " to ", destdir)
        plfile.copy(v, destdir)
      end
    end
  else
    print("no matching files for ", pattern, " in ", root)
  end
  local D = pldir.getdirectories(root)
  for index, v in ipairs(D) do
    if ( not string.find(v, ".git") ) then 
      print("Descending into ", v)
      recursive_descent(v)
    end
  end
end
recursive_descent(root)
