#!/usr/bin/env lua

local tmpl = dofile 'qsort.tmpl'

tmpl.SORT_ORDER = 'asc'
tmpl.FLDTYPE = 'uint64_t'
tmpl.COMPARATOR = '>'
-- print(tmpl 'declaration')
doth = tmpl 'declaration'
print("doth in _foo.h")
local f = assert(io.open("_foo.h", "w"))
f:write(doth)
f:close()

-- print(tmpl 'definition')
dotc = tmpl 'definition'
print("dotc in _foo.c")
local f = assert(io.open("_foo.c", "w"))
f:write(dotc)
f:close()
