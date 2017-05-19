local plpath = require 'pl.path'
local plfile = require 'pl.file'
local S = require 'subscriptions'
for k, v in pairs(S) do 
  local t = {}
  t[#t+1] = v.sig
  for i, d in ipairs(v.expand_as) do 
    local f = string.upper(d) .. "/lua/" .. "for_expander.lua"
    assert(plpath.isfile(f), "File not found " .. f)
    local s = plfile.read(f)
    s = string.gsub(s, "<<operator>>", k)
    t[#t+1] = s
    -- print(k, d)
  end
  t[#t+1] = "end"
  local x = table.concat(t, "\n")
  print(x)
end
