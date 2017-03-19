#!/bin/lua
local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Set Q_SRC_ROOT as /home/subramon/WORK/Q or some such")
local plpath = require 'pl.path'
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
require("trim")
n = #arg
assert( n == 2, "Specify infile and opdir")
infile = arg[1]
opdir  = arg[2]
assert(plpath.isfile(infile)) 
assert(plpath.isdir(opdir)) 
io.input(infile)
code = io.read("*all")
io.close()
--=========================================
incs = string.match(code, "//START_INCLUDES.*//STOP_INCLUDES")
if ( incs ) then 
  incs = string.gsub(incs, "//START_INCLUDES", "")
  incs = string.gsub(incs, "//STOP_INCLUDES", "")
end 
--=========================================
z = string.match(code, "//START_FUNC_DECL.*//STOP_FUNC_DECL")
assert(z ~= "")
z = string.gsub(z, "//START_FUNC_DECL", "")
z = string.gsub(z, "//STOP_FUNC_DECL", "")
--=========================================
opfile = opdir .. "/_" .. string.gsub(infile, ".c", ".h")
io.output(opfile)
if ( incs ) then 
  io.write(incs)
end
io.write('extern ' .. trim(z) .. ';') -- TODO get semi-colon on previous line
io.close()
os.exit()

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
 
