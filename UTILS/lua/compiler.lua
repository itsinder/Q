local plpath = require 'pl.path'
local plfile = require 'pl.file'
local QC_FLAGS= assert(os.getenv("QC_FLAGS"), "QC_FLAGS not provided")
local Q_LINK_FLAGS = assert(os.getenv("Q_LINK_FLAGS"), "Q_LINK_FLAGS not provided")
local tmp_c, tmp_h = "/tmp/dc.c", "/tmp/dc.h"

-- local function cleaned_h_file(file)
--   local cmd = string.format("cat %s | grep -v '#include'| cpp | grep -v '^#'", file)
--   local handle = io.popen(cmd)
--   local res = handle:read("*a")
--   handle:close()
--   return res
-- end
--
-- local function is_struct_file(file)
--   assert(plpath.isfile(file), "Could not find file " .. file)
--   if string.match(plfile.read(file), "struct ") then
--     -- TODO Now we need to get the name of the struct and compare it with what we
--     -- have in qc already, for now skipped
--     return true
--   else
--     return false
--   end
--   return nil
-- end
--
-- local function add_h_files_to_list(list, file_list)
--   for i=1,#file_list do
--     list[#list + 1] = cleaned_h_file(file_list[i])
--   end
--   return list
-- end
--
-- local function assemble_cdef(doth)
--   local struct_files = {}
--   local other_h_files = {}
--   for i=1,#doth do
--     local file = doth[i]
--     local contents = cleaned_h_file(file)
--     if is_struct_file(file) == true then
--       struct_files[#struct_files + 1] = contents
--     else
--       other_h_files[#other_h_files + 1] = contents
--     end
--   end
--   local all_files = struct_files
--   for i=1,#other_h_files do
--     all_files[#all_files + 1] = other_h_files[i]
--   end
--   return table.concat(all_files, "\n")
-- end
--
--
-- local function compile(doth, dotc, libname)
--   assert(dotc ~= nil and type(dotc) == "table" and #dotc >= 1, "need a valid table with at least one dot c file")
--   assert(doth ~= nil and type(doth) == "table" and #doth >= 1, "need a valid table of dot h files")
--   local q_cmd = string.format("gcc %s %s -I %s %s -o %s",
--   QC_FLAGS, table.concat(dotc, " "), table.concat(doth, " "), Q_LINK_FLAGS, libname)
--   local status = os.execute(q_cmd)
--   assert(status, "gcc failed for command: " .. q_cmd)
--   assert(plpath.isfile(libname), "Target " .. libname .. " not created")
--   print("Successfully created " .. libname)
--   return assemble_cdef(doth)
-- end

local function cleaned_h_file(h_file)
  local cmd = string.format("cat \"%s\" | grep -v '#include'| cpp | grep -v '^#'", h_file)
  local handle = io.popen(cmd)
  local res = handle:read("*a")
  handle:close()
  return res
end

local function write_to_file(content, fname)
  local file = assert(io.open(fname, "w+"), "unable to create " .. fname)
  print(content)
  print(content:gsub('\n', [[\n]]))
  local str = content:gsub('\n', [[\n]])
  file:write(str)
  file:close()

end

local function compile(doth, dotc, libname)
  assert(dotc ~= nil and type(dotc) == "string", "need a valid string that is the dot c file")
  assert(doth ~= nil and type(doth) == "string", "need a valid string that is the  dot h file")
  write_to_file(dotc, tmp_c)
  write_to_file(doth, tmp_h)
  local q_cmd = string.format("gcc %s %s -I %s %s -o lib%s.so", QC_FLAGS, tmp_c, tmp_h, Q_LINK_FLAGS, libname)
  local status = os.execute(q_cmd)
  assert(status, "gcc failed for command: " .. q_cmd)
  assert(plpath.isfile(libname), "Target " .. libname .. " not created")
  print("Successfully created " .. libname)
  return cleaned_h_file(tmp_h)
end
return compile
