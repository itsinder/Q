local Scalar = require 'libsclr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
return function (
  args
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local qc      = require "Q/UTILS/lua/q_core"
  local ffi     = require "Q/UTILS/lua/q_ffi"
  local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
  --=================================
  local hdr = [[
  typedef struct _rand_<<qtype>>_rec_type { 
    uint64_t seed;
    <<ctype>> lb;
    <<ctype>> ub;
  } RAND_<<qtype>>_REC_TYPE;
]]

  local tmpl
  local subs = {};
  local status
  assert(type(args) == "table")
  local qtype = assert(args.qtype)
  if ( qtype == "B1" ) then
    local spfn = require 'Q/OPERATORS/S_TO_F/lua/rand_specialize_B1'
    status, subs, tmpl = pcall(spfn, args)
    if ( not status ) then 
      print(subs) 
      return 
    else 
      return subs, tmpl
    end
  end

  local lb   = assert(args.lb)
  local ub   = assert(args.ub)
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
  assert(is_base_qtype(qtype))
  assert(len > 0, "vector length must be positive")
  lb = assert(to_scalar(lb, qtype))
  ub = assert(to_scalar(ub, qtype))
  assert(ub > lb, "upper bound should be strictly greater than lower bound")
  assert(type(len) == "number")
  assert(len > 0)

  --==============================
  -- Set c_mem using info from args
  local sz_c_mem = ffi.sizeof("RAND_" .. qtype .. "_REC_TYPE")
  local c_mem = assert(ffi.malloc(sz_c_mem), "malloc failed")
  c_mem = ffi.cast("RAND_" .. qtype .. "_REC_TYPE *", c_mem)
  local ctype = qconsts.qtypes[qtype].ctype
  c_mem.lb = ffi.cast(ctype .. " *", lb:cdata())[0]
  c_mem.ub = ffi.cast(ctype .. " *", ub:cdata())[0]
  c_mem.seed = seed
  --==============================
  if ( qconsts.iorf[qtype] == "fixed" ) then 
    subs.generator = "mrand48"
    subs.gen_type = "uint64_t"
    subs.scaling_code = "floor( (( (double) (x - INT_MIN) ) / ( (double) (INT_MAX) - (double)(INT_MIN) ) ) * (range + 1) )"
  elseif ( qconsts.iorf[qtype] == "floating_point" ) then 
    subs.generator = "drand48"
    subs.gen_type = "double"
    subs.scaling_code = "range * x"
  else
    assert(nil, "Unknown type " .. qtype)
  end
  --=========================
  tmpl = 'rand.tmpl'
  subs.fn = "rand_" .. qtype
  subs.c_mem = c_mem
  subs.out_ctype = qconsts.qtypes[qtype].ctype
  subs.len = len
  subs.out_qtype = qtype
  return subs, tmpl
end
