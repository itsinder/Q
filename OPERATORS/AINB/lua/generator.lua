  local plfile = require 'pl.file'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  local gen_code =  require("Q/UTILS/lua/gen_code")

  local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  local sp_fn = require 'ainb_specialize'
  local num_produced = 0
  for i, atype in ipairs(qtypes) do 
    for j, btype in ipairs(qtypes) do 
      local status, subs, tmpl = pcall(sp_fn, atype, btype)
      if ( status ) then 
        gen_code.doth(subs, tmpl, incdir)
        gen_code.dotc(subs, tmpl, srcdir)
        print("Generated ", subs.fn)
        num_produced = num_produced + 1
      else
        print(subs)
      end
    end
  end
  assert(num_produced > 0)
