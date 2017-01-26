#!/usr/bin/env lua
package.path = package.path.. ";../../../UTILS/lua/?.lua"
local tmpl = dofile 'txt_to.tmpl'
local incdir = "./gen_inc/"
local srcdir = "./gen_src/"
local subs = {}      -- a set to collect authors
function Entry (b) 
  subs[b.qtype] = b 
end
dofile("subs.lua")
-- for qtype in pairs(subs) do print(qtype) end
for k, v in pairs(subs) do 
  print("Processing ", k)
  tmpl.name = v.name
  tmpl.out_type_displ = v.out_type_displ 
  tmpl.out_type = v.out_type 
  tmpl.min_val = v.min_val 
  tmpl.max_val = v.max_val 
  tmpl.converter = v.converter
  -- print(tmpl 'declaration')
  doth = tmpl 'declaration'
  print("doth = ", doth)
  local fname = incdir .. "_" .. subs.fn .. ".h", "w"
  local f = assert(io.open(fname, "w"))
  f:write(doth)
  f:close()
  -- print(tmpl 'definition')
  dotc = tmpl 'definition'
  local fname = srcdir .. "_" .. subs.fn .. ".c", "w"
  local f = assert(io.open(fname, "w"))
  f:write(dotc)
  f:close()
end

