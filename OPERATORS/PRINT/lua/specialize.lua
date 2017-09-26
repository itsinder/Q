return function (
  qtype, 
  optargs
  )
    local plpath = require "pl.path"
    local qconsts = require 'Q/UTILS/lua/q_consts'
    local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
    assert(is_base_qtype(qtype))
    assert(plpath.isfile("to_txt.tmpl"))
    local default_fmt = '""'
    if ( ( qtype == "I1" ) or ( qtype == "I2" ) or 
         ( qtype == "I4" ) or ( qtype == "I8" ) ) then
      default_fmt = "%lld"
    elseif ( ( qtype == "F4" ) or ( qtype == "F8" ) ) then
      default_fmt = "%lf"
    else 
      assert(nil)
    end
    if ( optargs ) then
      assert(type(optargs) == "table")
      if (  optargs.format ) then 
        default_fmt = optargs.format
      end
    end

    local tmpl = 'to_txt.tmpl'
    local subs = {}
    subs.fn = qtype .. "_to_txt"
    subs.ctype = assert(qconsts.qtypes[qtype].ctype)
    subs.qtype = qtype
    subs.default_fmt = default_fmt
    return subs, tmpl
end
