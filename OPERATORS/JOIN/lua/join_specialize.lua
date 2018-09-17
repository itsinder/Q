return function (
  src_lnk_type,
  src_fld_type,
  dst_lnk_type,
  dst_fld_type,
  op
)
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
  local plfile = require 'pl.file'
  local subs = {}; local tmpl
  --assert(is_base_qtype(src_lnk_type), "type of in must be base type")
  assert(is_base_qtype(src_fld_type), "type of in must be base type")
  tmpl = "join.tmpl"
  subs.src_lnk_qtype = src_lnk_type
  subs.src_fld_qtype = src_fld_type
  subs.dst_lnk_qtype = src_fld_type
  subs.src_lnk_ctype = qconsts.qtypes[src_lnk_type].ctype
  subs.src_fld_ctype = qconsts.qtypes[src_fld_type].ctype
  subs.dst_lnk_ctype = qconsts.qtypes[src_fld_type].ctype
  subs.dst_fld_qtype = dst_fld_type
  subs.dst_fld_ctype = qconsts.qtypes[dst_fld_type].ctype
  subs.fn = "join" .. op .. "_" .. src_lnk_type .. "_" .. src_fld_type .. "_" .. 
  dst_lnk_type .. "_".. dst_fld_type
  return subs, tmpl
end
