  package.path = package.path.. ";../../../UTILS/lua/?.lua"
  local plfile = require 'pl.file'
  dofile '../../../UTILS/lua/globals.lua'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"

  require("aux")
  require("gen_doth")
  require("gen_dotc")
  plfile.delete("_qfns_f_to_s.lua")

  local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  -- ==================
  local str = "function ainb(afld, bfld)\n"
  str = str .. "  expander(\"ainb\",  afld, bfld)\n"
  str = str .. "end\n"
  local f = assert(io.open("_qfns_f_to_s.lua", "a"))
  f:write(str)
  f:close()
  -- ==================
  local str = 'require \'ainb_specialize\''
  loadstring(str)()
  for i, atype in ipairs(qtypes) do 
    for j, btype in ipairs(qtypes) do 
      local stat_chk = 'ainb_specialize'
      local stat_chk_fn = assert(_G[stat_chk], 
      "function not found " .. stat_chk)
      local status, subs, tmpl = pcall(stat_chk_fn, atype, btype)
      if ( status ) then 
        -- TODO Improve following.
        local T = dofile(tmpl)
        T.fn           = subs.fn
        T.atype        = subs.atype
        T.btype        = subs.btype
        gen_doth(T.fn, T, incdir)
        gen_dotc(T.fn, T, srcdir)
        print("Generated ", T.fn)
      end
    end
  end
