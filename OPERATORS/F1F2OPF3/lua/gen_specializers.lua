
local plfile = require 'pl.file'
local plpath = require 'pl.path'
assert(plpath.isfile("cmp_specialize.tmpl"), "File not found")
local x = plfile.read("cmp_specialize.tmpl")
--=======================
y = string.gsub(x, "<<operator>>", "vveq")
y = string.gsub(y, "<<comparator>>", "==")
plfile.write("vveq_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vvneq")
y = string.gsub(y, "<<comparator>>", "!=")
plfile.write("vvneq_specialize.lua", y)
assert(plpath.isfile("vvneq_specialize.lua"))
--=======================
y = string.gsub(x, "<<operator>>", "vvgeq")
y = string.gsub(y, "<<comparator>>", ">=")
plfile.write("vvgeq_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vvleq")
y = string.gsub(y, "<<comparator>>", "<=")
plfile.write("vvleq_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vvlt")
y = string.gsub(y, "<<comparator>>", "<")
plfile.write("vvlt_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vvgt")
y = string.gsub(y, "<<comparator>>", ">")
plfile.write("vvgt_specialize.lua", y)
--+++++++++++++++++++++++++
assert(plpath.isfile("arith_specialize.tmpl"), "File not found")
local x = plfile.read("arith_specialize.tmpl")

y = string.gsub(x, "<<operator>>", "vvadd")
y = string.gsub(y, "<<mathsymbol>>", "+")
plfile.write("vvadd_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vvsub")
y = string.gsub(y, "<<mathsymbol>>", "-")
plfile.write("vvsub_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vvmul")
y = string.gsub(y, "<<mathsymbol>>", "*")
plfile.write("vvmul_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vvdiv")
y = string.gsub(y, "<<mathsymbol>>", "/")
plfile.write("vvdiv_specialize.lua", y)
--=======================
--+++++++++++++++++++++++++
assert(plpath.isfile("bop_specialize.tmpl"), "File not found")
local x = plfile.read("bop_specialize.tmpl")

y = string.gsub(x, "<<operator>>", "vvand")
y = string.gsub(y, "<<mathsymbol>>", "&&")
plfile.write("vvand_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vvor")
y = string.gsub(y, "<<mathsymbol>>", "||")
plfile.write("vvor_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vvxor")
y = string.gsub(y, "<<mathsymbol>>", "^")
plfile.write("vvxor_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vvandnot")
y = string.gsub(y, "<<mathsymbol>>", "&& ~")
plfile.write("vvandnot_specialize.lua", y)
--=======================

print("ALL DONE")
