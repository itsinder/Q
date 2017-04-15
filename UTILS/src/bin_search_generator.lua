  local plpath = require 'pl.path'
  dofile '../lua/globals.lua'
  local srcdir = "../gen_src/"; assert(plpath.isdir(srcdir))
  local incdir = "../gen_inc/"; assert(plpath.isdir(incdir))

  require("aux")
  require("gen_doth")
  require("gen_dotc")

  local tmpl = "bin_search.tmpl"
  assert(plpath.isfile(tmpl))
  local qtypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  -- ==================
  for i, qtype in ipairs(qtypes) do 
     local T = dofile(tmpl)
     T.fn    = "bin_search_" .. qtype
     T.ftype = assert(g_qtypes[qtype].ctype)
     gen_doth(T.fn, T, incdir)
     gen_dotc(T.fn, T, srcdir)
     print("Generated ", T.fn)
  end
