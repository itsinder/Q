function gen_doth(fn, T, opdir)
  doth = T 'declaration'
  -- print("doth = ", doth)
  local fname = opdir .. "_" .. fn .. ".h", "w"
  local f = assert(io.open(fname, "w"))
  f:write(doth)
  f:close()
end
