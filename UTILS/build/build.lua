#!/bin/lua
local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Set Q_SRC_ROOT as /home/subramon/WORK/Q or some such")
local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/UTILS/build/?.lua"

local T = dofile("gen.lua")
for dir, scripts in pairs(T) do 
  plpath.chdir(rootdir .. "/" .. dir)
  local cwd = plpath.currentdir()
  print("Currently in ", cwd)
  local F = pldir.getfiles(cwd, "*.sh")
  print(F)
  for i, script in ipairs(scripts) do
    os.execute("bash " .. script)
    print(" Executing", script)
  end
end
print("All done")
