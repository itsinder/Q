local q_root = os.getenv("Q_ROOT")
assert(q_root, "Do export Q_ROOT=/home/subramon/Q/ or some such")
final_h  = q_root .. "/include/"
final_so = q_root .. "/lib/"

local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
local dbg = require 'Q/UTILS/lua.debugger'
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
local function clean_defs(file)
   local cmd = string.format("cat %s | grep -v '#include'| cpp | grep -v '^#'", file)
   local handle = io.popen(cmd)
   local res = handle:read("*a")
   handle:close()
   return res
    -- for line in io.lines(file) do
    --     if not string.match(line, "%s*#") then
    --         res[#res + 1] = line
    --     end
    -- end
    -- return table.concat(res, "\n")
end

local function is_struct_file(file)
  assert(plpath.isfile(file), "Could not find file " .. file)
    if string.match(plfile.read(file), "struct ") then
        return true
    else
        return false
    end
    return nil
end
 local function add_files_to_list(list, file_list)
     for i=1,#file_list do 
         list[#list + 1] = clean_defs(file_list[i])
     end
     return list
 end
local root = rootdir
local dirs_to_exclude = dofile("exclude_dir.lua")
local files_to_exclude = dofile("exclude_fil.lua")
--==========================
local tgt_o = opdir .. "/libq_core.so"
local tgt_h = opdir .. "/q_core.h"

local pattern = "*.c"
local cdir = opdir .. "/LUAC"
os.execute("rm -r -f " .. cdir)
plpath.mkdir(cdir)
xcopy(pattern, root, dirs_to_exclude, files_to_exclude, cdir)
--==========================
local pattern = "*.h"
local hdir = opdir .. "/LUAH"
os.execute("rm -r -f " .. hdir)
plpath.mkdir(hdir)
xcopy(pattern, root, dirs_to_exclude, files_to_exclude, hdir)
----------Create q.h
local q_struct_files = {}
local q_h = {}
local q_h_files = {}
local q_c_files = {}
local q_h_set = {} 
local h_files = pldir.getfiles(hdir, "*.h")
for num=1,#h_files do
    local file_path = h_files[num]
        if is_struct_file(file_path) then
            q_struct_files[#q_struct_files + 1] = file_path
        else
            q_h_files[#q_h_files + 1] = file_path
        end
        q_h_set[file_path] = true
end
--. for k,v in pairs(q_h_set) do
--.    print ("q", k)
--. end

q_h = add_files_to_list(q_h, q_struct_files)
q_h = add_files_to_list(q_h, q_h_files)
q_h = table.concat(q_h, "\n")
tgt_h = opdir .. "/q.h"
plfile.write(tgt_h, q_h)
pldir.copyfile(tgt_h, final_h)
print("Copied " .. tgt_h .. " to " .. final_h)

----------Create q_core.so
local FLAGS = "-std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp"
local q_so, q_h = opdir .. "/libq_core.so", opdir .. "/q_core.h"

local q_c_files = pldir.getfiles(cdir, "*.c")

local q_c = table.concat(q_c_files, " ")
local q_cmd = string.format("gcc %s %s -I %s -lgomp -pthread -shared -o %s", FLAGS, q_c, hdir, q_so)
q_cmd = "cd " .. cdir .. "; " .. q_cmd
local status = os.execute(q_cmd)
assert(status, "gcc failed")
assert(plpath.isfile(q_so), "Target " .. q_so .. " not created")
print("Successfully created " .. q_so)
pldir.copyfile(q_so, final_so)
print("Copied " .. q_so .. " to " .. final_so)
