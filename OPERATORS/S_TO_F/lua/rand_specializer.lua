return function (
  args
  )
  local qc = require "Q/UTILS/lua/q_core"

  assert(type(args) == "table")
  local lb   = assert(args.lb)
  local ub   = assert(args.ub)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  local seed   = args.seed
  if ( not seed ) then seed = 0 end
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  assert(is_base_qtype(qtype))
  assert(len > 0, "vector length must be positive")
  assert(type(lb) == "number")
  assert(type(ub) == "number")
  assert(ub > lb, "upper bound should be strictly greater than lower bound")
  local conv_fn = "txt_to_" .. qtype
  local out_ctype = g_qtypes[qtype].ctype
  local width = g_qtypes[qtype].width
  local c_mem = assert(qc.malloc(width), "malloc failed")
  qc.fill(c_mem, width, 0)
  local conv_fn = qc["txt_to_" .. qtype]
  local status 
  if ( g_iorf[qtype] == "fixed" ) then 
    status = conv_fn(tostring(val), 10, c_mem)
    generator = "mrand48"
    scaling_code = "ceil( (( (double) (x - INT_MIN) ) / ( (double) (INT_MAX) - (double)(INT_MIN) ) ) * range)"
  elseif ( g_iorf[qtype] == "floating_point" ) then 
    status  = conv_fn(tostring(val), c_mem)
    generator = "drand48"
    scaling_code = "range * x"
  else
    assert(nil, "Unknown type " .. qtype)
  end
  assert(status == 0, "Unable to create random vector ")
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
  subs.scaling_code = scale_code
  return subs, tmpl
end
