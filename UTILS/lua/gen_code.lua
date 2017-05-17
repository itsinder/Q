local plpath = require 'pl.path'

local fns = {}
local function do_replacement(tmpl, subs)
   local T = dofile(tmpl)
   for k,v in pairs(subs) do
      T[k] = v
   end
   return T
end


fns.dotc = function (subs, tmpl, opdir)
  local T = do_replacements(tmpl, subs)
  local dotc = T 'definition'
  if ( ( not opdir ) or ( opdir == "" ) ) then 
    return doth
  end
  assert(plpath.isdir(opdir), "Unable to find opdir " .. opdir)
  local fname = opdir .. "_" .. fn .. ".c", "w"
  local f = assert(io.open(fname, "w"))
  f:write(dotc)
  f:close()
end

fns.doth = function (subs, tmpl, opdir)
  local T = do_replacements(tmpl, subs)
  local doth = T 'declaration'
  if ( ( not opdir ) or ( opdir == "" ) ) then 
    return doth
  end
  assert(plpath.isdir(opdir), "Unable to find opdir " .. opdir)
  local fname = opdir .. "_" .. fn .. ".h", "w"
  local f = assert(io.open(fname, "w"))
  f:write(doth)
  f:close()
end




return fns
