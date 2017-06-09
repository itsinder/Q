return function (
  args
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local qc  = require "Q/UTILS/lua/q_core"
  local ffi = require "Q/UTILS/lua/q_ffi"
  local hdr = [[
  typedef struct _rand_<<qtype>>_rec_type { 
    uint64_t seed;
    <<ctype>> lb;
    <<ctype>> ub;
  } RAND_<<qtype>>_REC_TYPE;
]]

  assert(type(args) == "table")
  local lb   = assert(args.lb)
  local ub   = assert(args.ub)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  local seed   = args.seed

  hdr = string.gsub(hdr,"<<qtype>>", qtype)
  hdr = string.gsub(hdr,"<<ctype>>",  qconsts.qtypes[qtype].ctype)
  pcall(ffi.cdef, hdr)

  if ( seed ) then 
    assert(type(seed) == "number")
  else
    seed = 0 
  end
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  assert(is_base_qtype(qtype))
  assert(len > 0, "vector length must be positive")
  assert(type(lb) == "number")
  assert(type(ub) == "number")
  assert(ub > lb, "upper bound should be strictly greater than lower bound")

  local subs = {};
  --==============================
  -- Set c_mem using info from args
  local sz_c_mem = ffi.sizeof("RAND_" .. qtype .. "_REC_TYPE")
  local c_mem = assert(qc.malloc(sz_c_mem), "malloc failed")
  c_mem = ffi.cast("RAND_" .. qtype .. "_REC_TYPE *", c_mem)
  c_mem.lb = lb
  c_mem.ub = ub
  c_mem.seed = seed
  --==============================
  if ( qconsts.iorf[qtype] == "fixed" ) then 
    generator = "lrand48"
    subs.gen_type = "uint64_t"
    subs.scaling_code = "ceil( (( (double) (x - INT_MIN) ) / ( (double) (INT_MAX) - (double)(INT_MIN) ) ) * range)"
  elseif ( qconsts.iorf[qtype] == "floating_point" ) then 
    generator = "drand48"
    subs.scaling_code = "range * x"
    subs.gen_type = "double"
  else
    assert(nil, "Unknown type " .. qtype)
  end
  --=========================
  local tmpl = 'rand.tmpl'
  subs.fn = "rand_" .. qtype
  subs.c_mem = c_mem
  subs.out_ctype = qconsts.qtypes[qtype].ctype
  subs.len = len
  subs.out_qtype = qtype
  subs.generator = generator
  return subs, tmpl
end
