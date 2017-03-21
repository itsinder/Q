#!/bin/lua
function extract_fn_proto(infile)
--  assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
--  package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
--  local plpath = require 'pl.path'
--  local pldir  = require 'pl.dir'
--  assert(plpath.isfile(infile), "Input file not found")
  require 'trim'
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

--[[
foreach 
z = string.match(x, "//START.*//STOP")
> z
//START abc def //STOP
> x = "foo bar //START abc def //STOP hoo hah"
> z = string.match(x, "//START.*//STOP")
> z
//START abc def //STOP
> z = string.gsub(x, "//START", ""0
stdin:1: ')' expected near '0'
> z = string.gsub(x, "//START", "")
> z
foo bar  abc def //STOP hoo hah
> z = string.match(x, "//START.*//STOP")
> z
 abc def //STOP
 ]]
 
