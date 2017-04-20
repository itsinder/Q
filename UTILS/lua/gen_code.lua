local fns = {}

fns.dotc = function (fn, T, opdir)
  dotc = T 'definition'
  if ( ( not opdir ) or ( opdir == "" ) ) then 
    return doth
  end
  local plpath = require 'pl.path'
  assert(plpath.isdir(opdir), "Unable to find opdir " .. opdir)
  local fname = opdir .. "_" .. fn .. ".c", "w"
  local f = assert(io.open(fname, "w"))
  f:write(dotc)
  f:close()
end

fns.doth = function (fn, T, opdir)
  doth = T 'declaration'
  if ( ( not opdir ) or ( opdir == "" ) ) then 
    return doth
  end
  local plpath = require 'pl.path'
  assert(plpath.isdir(opdir), "Unable to find opdir " .. opdir)
  local fname = opdir .. "_" .. fn .. ".h", "w"
  local f = assert(io.open(fname, "w"))
  f:write(doth)
  f:close()
end

return fns
