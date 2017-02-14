function gen_dotc(fn, T, opdir)
  dotc = T 'definition'
  local fname = opdir .. "_" .. fn .. ".c", "w"
  local f = assert(io.open(fname, "w"))
  f:write(dotc)
  f:close()
end
