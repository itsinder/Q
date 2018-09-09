return function (
  src_lnk_type,
  src_fld_type,
  dst_fld_type,
  op
)
  print(src_lnk_type, src_fld_type)
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
  local plfile = require 'pl.file'
  local subs = {}; local tmpl
  assert(is_base_qtype(src_lnk_type), "type of in must be base type")
  assert(is_base_qtype(src_fld_type), "type of in must be base type")
  tmpl = "join.tmpl"
  subs.fn = "join" .. "_" .. src_lnk_type .. "_" .. src_fld_type .. "_" .. dst_fld_type
  print(subs.fn)
  --subs.fn = "join" .. "_" .. src_lnk_type
  subs.src_lnk_qtype = src_lnk_type
  subs.src_fld_qtype = src_fld_type
  subs.dst_lnk_qtype = src_fld_type
  subs.src_lnk_ctype = qconsts.qtypes[src_lnk_type].ctype
  subs.src_fld_ctype = qconsts.qtypes[src_fld_type].ctype
  subs.dst_lnk_ctype = qconsts.qtypes[src_fld_type].ctype
  subs.dst_fld_qtype = dst_fld_type
  subs.dst_fld_ctype = qconsts.qtypes[dst_fld_type].ctype
--  if op == "sum" then
--    if ( ( subs.src_fld_qtype == "I1" ) or ( subs.src_fld_qtype == "I2" ) or 
--      ( subs.src_fld_qtype == "I4" ) or ( subs.src_fld_qtype == "I8" ) ) then
--      subs.out_ctype = "int64_t" 
--      subs.out_qtype = "I8" 
--    elseif ( ( subs.src_fld_qtype == "F4" ) or ( subs.src_fld_qtype == "F8" ) ) then
--      subs.out_ctype = "double" 
--      subs.out_qtype = "F8" 
--    end
--  elseif op == "min" or op == "max" then
--    subs.out_ctype = qconsts.qtypes[src_fld_type].ctype
--    subs.out_qtype = src_fld_type
--  elseif op == "min_idx" or op == "max_idx" or op == "count" or op == "and" or op == "or" then
--    subs.out_ctype = "int64_t"
--    subs.out_qtype = "I8"
--  else
--    -- TODO : for arbitary abd exists?
--  end
  
  return subs, tmpl
end
