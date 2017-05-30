return function (infile)

local plpath = require 'pl.path'
local plfile = require 'pl.file'
--  assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
--  package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
  assert(plpath.isfile(infile), "Input file not found " .. infile)
  code = plfile.read(infile)
  assert(code and code ~= "", "Input file is empty " .. infile)
  --=========================================
  z = string.match(code, "//START_FUNC_DECL.*//STOP_FUNC_DECL")
  assert(z, "Could not find stuff in START_FUNC_DECL .. STOP_FUNC_DECL for file " .. infile)
  z = string.gsub(z, "//START_FUNC_DECL", "")
  z = string.gsub(z, "//STOP_FUNC_DECL", "")
  --=========================================
  return 'extern ' .. stringx.strip(z) .. ';'
end
