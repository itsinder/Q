function gen_doth(fn, T, opdir)
  local plpath = require 'pl.path'
  doth = T 'declaration'
  if ( ( not opdir ) or ( opdir == "" ) ) then 
    return doth
  end
  assert(plpath.isdir(opdir))
  -- print("doth = ", doth)
  local fname = opdir .. "_" .. fn .. ".h", "w"
  local f = assert(io.open(fname, "w"))
  f:write(doth)
  f:close()
end
