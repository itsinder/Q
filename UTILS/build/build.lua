#!/bin/lua
local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Set Q_SRC_ROOT as /home/subramon/WORK/Q or some such")
local plpath = require 'pl.path'
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/UTILS/build/?.lua"

T = dofile("gen.lua")

