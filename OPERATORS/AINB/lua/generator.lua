  local plfile = require 'pl.file'
  require 'UTILS/lua/globals.lua'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  local gen_code =  require("UTILS/lua/gen_code")

  local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  local sp_fn = require 'ainb_specialize'
  for i, atype in ipairs(qtypes) do 
    for j, btype in ipairs(qtypes) do 
      local status, subs, tmpl = pcall(sp_fn, atype, btype)
      if ( status ) then 
        -- TODO Improve following.
        local T = dofile(tmpl)
        T.fn           = subs.fn
        T.atype        = subs.atype
        T.btype        = subs.btype
        gen_code.doth(T.fn, T, incdir)
        gen_code.dotc(T.fn, T, srcdir)
        print("Generated ", T.fn)
      end
    end
  end
