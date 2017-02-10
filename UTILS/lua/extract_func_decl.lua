#!/bin/lua
require 'pl'
-- Move isdir to proper place. Use appropriate package
function is_dir(fn) -- TODO 
  return true
--      return (posix.stat(fn, "type") == 'directory')
end

package.path = package.path.. ";../../../UTILS/lua/?.lua"
require("is_file")
require("trim")
n = #arg
assert( n == 2 ) 
infile = arg[1]
opdir  = arg[2]
assert(is_file(infile)) -- TODO improve
assert(is_dir(opdir)) -- TODO improve
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
 
