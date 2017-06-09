  local qconsts = require 'Q/UTILS/lua/q_consts'
  local plpath = require 'pl.path'
  local srcdir = "../gen_src/"; assert(plpath.isdir(srcdir))
  local incdir = "../gen_inc/"; assert(plpath.isdir(incdir))
  local gen_code = require("Q/UTILS/lua/gen_code")

  local tmpl = "bin_search.tmpl"
  assert(plpath.isfile(tmpl))
  local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  -- ==================
  for i, qtype in ipairs(qtypes) do 
     local subs = {} 
     subs.fn    = "bin_search_" .. qtype
     subs.ftype = assert(qconsts.qtypes[qtype].ctype)
     gen_code.doth(subs, tmpl, incdir)
     gen_code.dotc(subs, tmpl, srcdir)
     print("Generated ", subs.fn)
  end
