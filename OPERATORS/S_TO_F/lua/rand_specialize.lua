local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'
return function (
  args
  )
  local qc  = require "Q/UTILS/lua/q_core"
  local ffi = require "Q/UTILS/lua/q_ffi"

  assert(type(args) == "table")
  local lb   = assert(args.lb)
  local ub   = assert(args.ub)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  local seed   = assert(args.seed)
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  assert(is_base_qtype(qtype))
  assert(len > 0, "vector length must be positive")
  assert(type(lb) == "number")
  assert(type(ub) == "number")
  local conv_fn = "txt_to_" .. qtype
  local out_ctype = qconsts.qtypes[qtype].ctype
  local sz_c_mem = ffi.sizeof('RANDOM_' .. qtype .. '_REC_TYPE');

  local c_mem = assert(qc.malloc(sz_c_mem), "malloc failed")
  ffi.fill(c_mem, width, 0)
  local conv_fn = qc["txt_to_" .. qtype]
  local status 
  status = conv_fn(tostring(val), c_mem)
  assert(status, "Unable to create random vector ")
  if ( qconsts.iorf[qtype] == "fixed" ) then 
    generator = "mrand48"
    scaling_code = "ceil( (( (double) (x - INT_MIN) ) / ( (double) (INT_MAX) - (double)(INT_MIN) ) ) * range)"
  elseif ( qconsts.iorf[qtype] == "floating_point" ) then 
    generator = "drand48"
    scaling_code = "range * x"
  else
    assert(nil, "Unknown type " .. qtype)
  end
  --=========================
  -- local x = ffi.cast(out_ctype .. " *", c_mem); print(x[0])
  local tmpl = 'rand.tmpl'
  local subs = {};
  subs.fn = "rand_" .. qtype
  subs.c_mem = c_mem
  subs.out_ctype = out_ctype
  subs.len = len
  subs.out_qtype = qtype
  subs.generator = generator
  subs.scale_code = scale_code
  return subs, tmpl
end
