return function (
  qtype, 
  optargs
  )
    local plpath = require "pl.path"
    local qconsts = require 'Q/UTILS/lua/q_consts'
    assert(plpath.isfile("to_txt.tmpl"))
    local default_fmt = '""'
    if ( optargs ) then
      assert(type(optargs) == "table")
      default_fmt = optargs.format or default_fmt
      
    end
    local tmpl = 'to_txt.tmpl'
    local subs = {}
    subs.fn = qtype .. "_to_txt"
    subs.ctype = assert(qconsts.qtypes[qtype].ctype)
    subs.qtype = qtype
    subs.default_fmt = default_fmt
    return subs, tmpl
end
