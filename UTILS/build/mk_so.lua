  package.path = package.path.. ";../../../UTILS/lua/?.lua"
-- local plutils = require 'pl.util'
-- local plpath = require 'pl.path'
-- local dbg = require 'debugger'
local plfile = require 'pl.file'
local pldir = require 'pl.dir'
local plpath = require 'pl.path'
--=================================
function recursive_descent(
  pattern, 
  root,
  destdir
  )
  local F = pldir.getfiles(root, pattern)
  if ( ( F )  and ( #F > 0 ) ) then 
    for index, v in ipairs(F) do
      print("Copying ", v, " to ", destdir)
      plfile.copy(v, destdir)
    end
  else
    print("no matching files for ", pattern, " in ", root)
  end
  local D = pldir.getdirectories(root)
  for index, v in ipairs(D) do
    if ( ( string.find(v, ".git") ) or 
       ( string.find(v, "DEPRECATED") ) or 
       ( string.find(v, "experimental") ) ) then 
       print("Skipping " .. v)
     else
      -- print("Descending into ", v)
      recursive_descent(pattern, v, destdir)
    end
  end
end
  --==========================
function xcopy(
  pattern,
  root,
  destdir
  )
  if ( plpath.isdir(destdir) ) then 
    plpath.rmdir(destdir)
  end
  plpath.mkdir(destdir)
  recursive_descent(pattern, root, destdir)
  end
--============
local root = "/home/subramon/WORK/Q/"
X = dofile("exclude_from_so.lua")
  --==========================
local pattern = "*.c"
local cdir = "/tmp/LUAC/"
xcopy(pattern, root, cdir)
  --==========================
local pattern = "*.h"
local hdir = "/tmp/LUAH/"
xcopy(pattern, root, hdir)
  --==========================

FLAGS = "-std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic "

command = "gcc " .. FLAGS .. cdir .. "*.c -I" .. hdir
print(command)
os.execute(command)
