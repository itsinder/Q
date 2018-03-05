return function (
  qtype, 
  optargs
  )
    local plpath = require "pl.path"
    local qconsts = require 'Q/UTILS/lua/q_consts'
    local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
    local fmt = ""
    assert(is_base_qtype(qtype))
    assert(plpath.isfile("to_txt.tmpl"))
    if ( optargs ) then
      assert(type(optargs) == "table")
      if (  optargs.format ) then 
        fmt = optargs.format
        assert(type(fmt) == "string")
      end
    end
    local default_fmt = "PR" .. qtype

    local tmpl = 'to_txt.tmpl'
    local subs = {}
    subs.fn = qtype .. "_to_txt"
    subs.ctype = assert(qconsts.qtypes[qtype].ctype)
    subs.qtype = qtype
    subs.fmt   = fmt
    subs.default_fmt   = default_fmt
    return subs, tmpl
end
