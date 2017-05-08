local q_root = os.getenv("Q_ROOT")
assert(q_root, "Do export Q_ROOT=/home/subramon/Q/ or some such")
final_h  = q_root .. "/include/"
final_so = q_root .. "/lib/"

local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
-- local dbg = require 'debugger'
local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
local plfile = require 'pl.file'
local nargs = assert(#arg == 1, "Arguments are <opdir>")
local opdir = arg[1]
assert(plpath.isdir(opdir), "Directory not found: " .. opdir)
assert(plpath.isdir(final_h), "Directory not found: " .. final_h)
assert(plpath.isdir(final_so), "Directory not found: " .. final_so)
file_names = {} -- lists files seen to point out duplication
-- dbg()
--=================================
function recursive_descent(
  pattern, 
  root,
  dirs_to_exclude,
  files_to_exclude,
  destdir
  )
  local F = pldir.getfiles(root, pattern)
  if ( ( F )  and ( #F > 0 ) ) then 
    for index, v in ipairs(F) do
      found = false
      if ( files_to_exclude ) then 
        for i2, v2 in ipairs(files_to_exclude) do
          if ( string.find(v, v2) ) then 
            found = true
          end
        end
      end
      if ( found ) then 
        -- print("Skipping file " .. v)
      else
        -- print("Copying ", v, " to ", destdir)
        plfile.copy(v, destdir)
      end
    end
  else
    -- print("no matching files for ", pattern, " in ", root)
  end
  local D = pldir.getdirectories(root)
  for index, v in ipairs(D) do
    found = false
    if ( dirs_to_exclude ) then 
      for i2, v2 in ipairs(dirs_to_exclude) do
        start, stop =  string.find(v, v2)
        if ( stop == string.len(v) ) then 
          found = true
        end
      end
    end
    if ( found ) then 
       -- print("Skipping directory " .. v)
     else
      -- print("Descending into directory ", v)
      recursive_descent(pattern, v, dirs_to_exclude, files_to_exclude, destdir)
    end
  end
end
  --==========================
function xcopy(
  pattern,
  root,
  dirs_to_exclude, 
  files_to_exclude,
  destdir
  )
  -- dbg()
--  print(root, destdir)
--  if ( plpath.isdir(destdir) ) then 
--    plpath.rmdir(destdir)
--  end
--  plpath.mkdir(destdir)
  recursive_descent(pattern, root, dirs_to_exclude, files_to_exclude, destdir)
  end
--============
local root = rootdir 
local dirs_to_exclude = dofile("exclude_dir.lua")
local files_to_exclude = dofile("exclude_fil.lua")
  --==========================
local tgt_o = opdir .. "/libq.so"
local tgt_h = opdir .. "/q.h"

local pattern = "*.c"
local cdir = opdir .. "/LUAC/"
os.execute("rm -r -f " .. cdir)
plpath.mkdir(cdir)
xcopy(pattern, root, dirs_to_exclude, files_to_exclude, cdir)
  --==========================
local pattern = "*.h"
local hdir = opdir .. "/LUAH/"
os.execute("rm -r -f " .. hdir)
plpath.mkdir(hdir)
xcopy(pattern, root, dirs_to_exclude, files_to_exclude, hdir)

command = "cat " .. hdir .. "*.h | grep -v '^#' > " .. tgt_h
local status = os.execute(command)
status = os.execute(command)
print("Successfully created " .. tgt_h)
print("Copied " .. tgt_h .. " to " .. final_h)
  --==========================
local pattern = "*.tmpl"
local tdir = "/tmp/TEMPLATES/"
os.execute("rm -r -f " .. tdir)
plpath.mkdir(tdir)
xcopy(pattern, root, dirs_to_exclude, files_to_exclude, tdir)
  --==========================

FLAGS = "-std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp "

print("-----------------------")
command = "gcc " .. FLAGS .. cdir .. "/*.c -I" .. hdir .. 
  " -shared -o " .. tgt_o
status = os.execute(command)
assert(status, "gcc failed")
assert(plpath.isfile(tgt_o), "Target " .. tgt_o .. " not created")
print("Successfully created " .. tgt_o)
pldir.copyfile(tgt_o, final_so)

--========== Create q_core.so 
local q_core = dofile('core_c_files.lua')
plpath.mkdir(cdir .. "/q_core/")
c_dst = cdir .. "/q_core/" 
assert(plpath.isdir(c_dst))
for i, v in ipairs(q_core) do
  src = cdir .. "/" .. v
  assert(plpath.isfile(src), "File not found " .. src)
  pldir.copyfile(src, c_dst)
  -- print("Copying " .. src .. " to " .. c_dst)
end

tgt_o = opdir .. "/libq_core.so"
command = "gcc " .. FLAGS .. c_dst .. "/*.c -I" .. hdir .. 
  " -shared -o " .. tgt_o
dbg = require 'debugger'
status = os.execute(command)
assert(status, "Command failed " .. command)
pldir.copyfile(tgt_o, final_so)

local extract_fn_proto = require 'extract_fn_proto'
local T = {}
local q_core = dofile('core_c_files.lua')
for i, v in ipairs(q_core) do
  local x = string.gsub(v, "%.c", ".h") 
  local f = hdir .. "/" .. x
  local isfile = plpath.isfile(f)
  if ( not isfile ) then 
    local f = hdir .. "/_" .. x
    assert(plpath.isfile(f), "File not found " .. f)
  end
  local y = plfile.read(f)
  T[#T+1] = y
end

local q_core_h = table.concat(T, "\n")

local tgt_h = opdir .. "/q_core.h"
plfile.write(tgt_h, q_core_h)

pldir.copyfile(tgt_h, final_h)
-- TODO hack
local res = {}
-- Adding mmap stuff manually
for line in io.lines("/tmp/LUAH/mmap_struct.h") do
 if not string.match(line, "%s*#") then
      res[#res + 1] = line
   end
end

-- Adding mmap stuff manually
for line in io.lines("/tmp/LUAH/_f_mmap.h") do
 if not string.match(line, "%s*#") then
      res[#res + 1] = line
   end
end

-- Adding mmap stuff manually
for line in io.lines("/tmp/LUAH/_f_munmap.h") do
 if not string.match(line, "%s*#") then
      res[#res + 1] = line
   end
end


for line in io.lines(tgt_h) do
   if not string.match(line, "%s*#") then
      res[#res + 1] = line
   end
end

local content = table.concat(res, "\n")
local f = io.open(final_h .."/q_core.h" , "w")
f:write(content)
f:close()
print("Copied " .. tgt_h .. " to " .. final_h)
