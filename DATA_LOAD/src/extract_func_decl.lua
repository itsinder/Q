#!/bin/lua
package.path = package.path.. ";../../UTILS/lua/?.lua"
require("is_file")
n = #arg
infile = arg[1]
assert( n == 1 ) 
assert(is_file(infile))
io.input(infile)
code = io.read("*all")
z = string.match(code, "//START_FUNC_DECL.*//STOP_FUNC_DECL")
assert(z ~= "")
z = string.gsub(z, "//START_FUNC_DECL", "")
z = string.gsub(z, "//STOP_FUNC_DECL", "")
print('extern ' .. z .. ';')
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
 
