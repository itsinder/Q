#!/bin/lua
return function (infile)

local trim = require 'trim'
local plpath = require 'pl.path'
--  assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
--  package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
  assert(plpath.isfile(infile), "Input file not found")
  assert(io.input(infile), "Input file not found")
  code = io.read("*all")
  io.close()
  --=========================================
  z = string.match(code, "//START_FUNC_DECL.*//STOP_FUNC_DECL")
  assert(z, "Could not find stuff in START_FUNC_DECL .. STOP_FUNC_DECL")
  z = string.gsub(z, "//START_FUNC_DECL", "")
  z = string.gsub(z, "//STOP_FUNC_DECL", "")
  --=========================================
  return 'extern ' .. trim(z) .. ';'
end
