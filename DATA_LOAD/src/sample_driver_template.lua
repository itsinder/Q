#!/usr/bin/env lua
package.path = package.path.. ";../../UTILS/lua/?.lua"
local tmpl = dofile 'txt_to.tmpl'
local subs = dofile 'txt_to_subs.lua'

for k, v in ipairs(subs)  do
  tmpl = subs[k]
end
-- print(tmpl 'declaration')
doth = tmpl 'declaration'
print("doth = ", doth)
-- print(tmpl 'definition')
dotc = tmpl 'definition'
print("dotc = ", dotc)
