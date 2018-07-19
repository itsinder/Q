local plpath = require 'pl.path'
local plfile = require 'pl.file'
local qconsts = require 'Q/UTILS/lua/q_consts'
local QC_FLAGS= assert(os.getenv("QC_FLAGS"), "QC_FLAGS not provided")
local LD_LIBRARY_PATH = assert(os.getenv("LD_LIBRARY_PATH"), "LD_LIBRARY_PATH not provided")
local Q_PATH = LD_LIBRARY_PATH:sub(LD_LIBRARY_PATH:find('[^:]*$'))
local Q_ROOT = os.getenv("Q_ROOT") 
local q_src_root = os.getenv("Q_SRC_ROOT")
assert(plpath.isdir(q_src_root))
local H_DIR = Q_ROOT .. "/include/" 
local Q_LINK_FLAGS = assert(os.getenv("Q_LINK_FLAGS"), "Q_LINK_FLAGS not provided")
-- local tmp_c, tmp_h = "/tmp/dc.c", "/tmp/dc.h"

local function cleaned_h_file(h_file)
  -- local cmd = string.format([[cat %s | sed 's/\\n/\n/g'| grep -v '#include'| cpp | grep -v '^#']], h_file)
  local cmd = string.format([[cat %s | grep -v '#include'| cpp | grep -v '^#']], h_file)
  local handle = io.popen(cmd)
  local res = handle:read("*a")
  handle:close()
  return res
end

local function write_to_file(content, fname)
  local file = assert(io.open(fname, "w+"), "unable to create " .. fname)
  -- local str = content:gsub('\n', [[\n]])
  file:write(content)
  file:close()

end

local function compile(doth, h_path, dotc, so_path, libname)
  assert(doth ~= nil and type(doth) == "string", "need a valid string that is the  dot h file")
  assert( h_path ~= nil and type(h_path) == "string", "need a valid h_path")
  assert(dotc ~= nil and type(dotc) == "string", "need a valid string that is the dot c file")
  assert(so_path ~= nil and type(so_path) == "string", "need a valid so_path")
  local tmp_c = string.format("/tmp/_%s.c", libname)
  local tmp_h = string.format("/tmp/_%s.h", libname)
  write_to_file(dotc, tmp_c)
  write_to_file(doth, tmp_h)
  local incs = string.format("-I /tmp/ -I %s -I %s ", q_src_root .. "/UTILS/inc", q_src_root .. "/UTILS/gen_inc")
  local q_cmd = string.format("gcc %s %s %s %s -o %s", 
       QC_FLAGS, tmp_c, incs, Q_LINK_FLAGS, so_path)
  local status = os.execute(q_cmd)
  assert(status == 0, "gcc failed for command: " .. q_cmd)
  assert(plpath.isfile(so_path), "Target " .. libname .. " not created")
  -- print("Successfully created " .. libname)
  -- if qconsts.debug ~= true then
  --   plfile.delete(tmp_c)
  --   plfile.delete(tmp_h)
  -- end
  local h_file = cleaned_h_file(tmp_h)
  plfile.write(h_path, h_file)
end

return compile
