#!/bin/lua
local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/UTILS/build/?.lua"
local log = require 'log'

local T = dofile("gen.lua")
for i, v in ipairs(T) do 
  plpath.chdir(rootdir .. "/" .. v.dir)
  local cwd = assert(plpath.currentdir())
  print("Currently in ", cwd)
  local F = pldir.getfiles(cwd, "*.sh")
  for i, script in ipairs(v.scripts) do
    print(" Executing ", script)
    status = os.execute("bash " .. script)
    assert ( status == 0, " failure at " .. script, " in ", cwd)
  end
end
print("All done")
