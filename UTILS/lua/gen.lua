local fns = {}

fns.dotc = function (fn, T, opdir)
  dotc = T 'definition'
  local fname = opdir .. "_" .. fn .. ".c", "w"
  local f = assert(io.open(fname, "w"))
  f:write(dotc)
  f:close()
end

fns.doth = function (fn, T, opdir)
  local plpath = require 'pl.path'
  doth = T 'declaration'
  if ( ( not opdir ) or ( opdir == "" ) ) then 
    return doth
  end
  assert(plpath.isdir(opdir), "Unable to find opdir " .. opdir)
  -- print("doth = ", doth)
  local fname = opdir .. "_" .. fn .. ".h", "w"
  local f = assert(io.open(fname, "w"))
  f:write(doth)
  f:close()
end

return fns

--=====
--
-- local gen = require 'gen'
-- gen.dotc(....)
-- gen.doth(....)
