
return function (
  args
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local qc = require "Q/UTILS/lua/q_core"
  local ffi = require "Q/UTILS/lua/q_ffi"
  
  assert(type() == "table")
  local x = assert(args.x)
  assert(type(x) == "Column")
  local qtype = x:fldtype()
  local siz = x:length()
  local num_quantiles = assert(args.num_quantiles)
  local err = assert(args.err)
  local cfld = args.where
  if ( cfld ) then 
    assert(type(cfld) == "Column")
    assert(cfld:fldtype() == "B1")
    assert(nil, "TODO NOT IMPLEMENTED")
  end

  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  assert(is_base_qtype(qtype))
  assert(type(siz) == "number")
  assert( siz > 0, "vector length must be positive")
  assert(type(num_quantiles == "number"), "num quantiles must be a number")
  assert( num_quantiles > 0, "num quantiles must be positive")
  assert( num_quantiles < siz, "cannot have more quantiles than numbers")
  assert(type(err) == "number")
  assert( err >= 0 and err <= 1, "error must be a decimal")

  --==============================
  local subs = {}
  local tmpls = {'approx_quantile.tmpl', 'New.tmpl', 'Output.tmpl', 'Collapse.tmpl'}

  subs.fn = "aq_" .. qtype
  subs.ctype = qconsts.qtypes[qtype].ctype
  subs.qtype = qtype
  return subs, tmpls
end
