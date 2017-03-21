  package.path = package.path.. ";../../../UTILS/lua/?.lua"
-- local plutils = require 'pl.util'
-- local dbg = require 'debugger'
local pl = require 'pl'
--=================================
function recursive_descent(
  pattern, 
  root,
  excludes,
  destdir
  )
  local F = pl.dir.getfiles(root, pattern)
  if ( ( F )  and ( #F > 0 ) ) then 
    for index, v in ipairs(F) do
      print("Copying ", v, " to ", destdir)
      pl.file.copy(v, destdir)
    end
  else
    print("no matching files for ", pattern, " in ", root)
  end
  local D = pl.dir.getdirectories(root)
  for index, v in ipairs(D) do
    found = false
    if ( excludes ) then 
      for i2, v2 in ipairs(excludes) do
        if ( string.find(v, v2) ) then 
          found = true
        end
      end
    end
    if ( found ) then 
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
  excludes, 
  destdir
  )
  if ( pl.path.isdir(destdir) ) then 
    pl.path.rmdir(destdir)
  end
  pl.path.mkdir(destdir)
  recursive_descent(pattern, root, destdir)
  end
--============
local root = "/home/subramon/WORK/Q/"
local excludes = dofile("exclude_from_so.lua")
  --==========================
local tgt = "/tmp/libq.so"

local pattern = "*.c"
local cdir = "/tmp/LUAC/"
pl.path.rmdir(cdir)
pl.path.mkdir(cdir)
xcopy(pattern, root, cdir)
  --==========================
local pattern = "*.h"
local hdir = "/tmp/LUAH/"
pl.path.rmdir(hdir)
pl.path.mkdir(hdir)
xcopy(pattern, root, excludes, hdir)
  --==========================

FLAGS = "-std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp "

command = "gcc " .. FLAGS .. cdir .. "*/.c -I" .. hdir .. 
  " -shared -o " .. tgt
print(command)
status = os.execute(command)
assert(status, "gcc failed")
assert(pl.dir.isfile(tgt), "Target not created")
