local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
local dbg = require 'debugger'
local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
local plfile = require 'pl.file'
file_names = {} -- lists files seen to point out duplication
-- dbg()
--=================================
function recursive_descent(
  pattern, 
  root,
  xdir,
  xfil,
  destdir
  )
  local F = pldir.getfiles(root, pattern)
  if ( ( F )  and ( #F > 0 ) ) then 
    for index, v in ipairs(F) do
      found = false
      if ( xfil ) then 
        for i2, v2 in ipairs(xfil) do
          if ( string.find(v, v2) ) then 
            found = true
          end
        end
      end
      if ( found ) then 
        print("Skipping file " .. v)
      else
        -- base_file_name = from last / to end
        -- if ( files[base_file_name] ) then
        --   files[base_file_name] = true
        -- end

        print("Copying ", v, " to ", destdir)
        plfile.copy(v, destdir)
      end
    end
  else
    print("no matching files for ", pattern, " in ", root)
  end
  local D = pldir.getdirectories(root)
  for index, v in ipairs(D) do
    found = false
    if ( xdir ) then 
      for i2, v2 in ipairs(xdir) do
        if ( string.find(v, v2) ) then 
          found = true
        end
      end
    end
    if ( found ) then 
       print("Skipping directory " .. v)
     else
      -- print("Descending into ", v)
      recursive_descent(pattern, v, xdir, xfil, destdir)
    end
  end
end
  --==========================
function xcopy(
  pattern,
  root,
  xdir, 
  xfil,
  destdir
  )
  -- dbg()
--  print(root, destdir)
--  if ( plpath.isdir(destdir) ) then 
--    plpath.rmdir(destdir)
--  end
--  plpath.mkdir(destdir)
  recursive_descent(pattern, root, xdir, xfil, destdir)
  end
--============
local root = "/home/subramon/WORK/Q/"
local xdir = dofile("exclude_dir.lua")
local xfil = dofile("exclude_fil.lua")
  --==========================
local tgt = "/tmp/libq.so"

local pattern = "*.c"
local cdir = "/tmp/LUAC/"
os.execute("rm -r -f " .. cdir)
plpath.mkdir(cdir)
xcopy(pattern, root, xdir, xfil, cdir)
  --==========================
local pattern = "*.h"
local hdir = "/tmp/LUAH/"
os.execute("rm -r -f " .. hdir)
plpath.mkdir(hdir)
xcopy(pattern, root, xdir, xfil, hdir)

command = "cat " .. hdir .. "*.h > /tmp/q.h"
os.execute(command)
  --==========================
local pattern = "*.tmpl"
local tdir = "/tmp/TEMPLATES/"
os.execute("rm -r -f " .. tdir)
plpath.mkdir(tdir)
xcopy(pattern, root, xdir, xfil, tdir)
  --==========================

FLAGS = "-std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp "

print("-----------------------")
command = "gcc " .. FLAGS .. cdir .. "/*.c -I" .. hdir .. 
  " -shared -o " .. tgt
status = os.execute(command)
assert(status, "gcc failed")
assert(plpath.isfile(tgt), "Target " .. tgt .. " not created")
print("Successfully created " .. tgt)
