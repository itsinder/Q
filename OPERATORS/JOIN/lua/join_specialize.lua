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
  if ( dst_fld_type == "I1" ) then subs.initial_val = "INT8_MIN" end
  if ( dst_fld_type == "I2" ) then subs.initial_val = "INT16_MIN" end
  if ( dst_fld_type == "I4" ) then subs.initial_val = "INT32_MIN" end
  if ( dst_fld_type == "I8" ) then subs.initial_val = "INT64_MIN" end
  -- Updated the initial val for F4 and F8
  -- FLT_MIN and DBL_MIN have minimum, normalized, positive value of float and double
  -- so for negative values in input vector, these are not appropriate initial values
  if ( dst_fld_type == "F4" ) then subs.initial_val = "-FLT_MAX-1" end
  if ( dst_fld_type == "F8" ) then subs.initial_val = "-DBL_MAX-1" end
  assert(subs.initial_val)
  return subs, tmpl
end
