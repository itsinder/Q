  local gen_code = require 'Q/UTILS/lua/gen_code'
  local plpath = require 'pl.path'
  local srcdir = '../gen_src/'
  local incdir = '../gen_inc/'
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end 
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end 
  local qtypes
  if ( arg[1] ) then 
    qtypes = { arg[1] }
  else 
    qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  end
  local num_produced = 0
  --==================================================
  local sp_fn = require 'specialize'
  for i, qtype in ipairs(qtypes) do
    local status, subs, tmpl = pcall(sp_fn, qtype)
    assert(status, subs)
    gen_code.doth(subs, tmpl, incdir)
    gen_code.dotc(subs, tmpl, srcdir)
    print("Produced ", subs.fn)
    num_produced = num_produced + 1
  end
  assert(num_produced > 0)
