#!/usr/bin/env lua

local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
require 'globals'

local tmpl = dofile 'qsort.tmpl'

order = { 'asc', 'dsc' }
qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }

for i, o in ipairs(order) do 
  for k, f in ipairs(qtypes) do 
    tmpl.SORT_ORDER = o
    tmpl.QTYPE = f
    tmpl.NAME = "qsort_" .. o .. "_" .. f
    tmpl.FLDTYPE = g_qtypes[f].ctype
    -- TODO Check below is correct order/comparator combo
    if o == "asc" then c = "<" end
    if o == "dsc" then c = ">" end
    tmpl.COMPARATOR = c
    --======================
    fn = "qsort_" .. o .. "_" .. f 
    doth = tmpl 'declaration'
    fname = "../gen_inc/" .. "_" .. fn .. ".h" 
    local f = assert(io.open(fname, "w"))
    f:write(doth)
    f:close()
    --======================
    dotc = tmpl 'definition'
    fname = "../gen_src/" .. "_" .. fn .. ".c" 
    local f = assert(io.open(fname, "w"))
    f:write(dotc)
    f:close()
    --======================
  end
end
