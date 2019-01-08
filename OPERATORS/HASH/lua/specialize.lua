local is_in    = require 'Q/UTILS/lua/is_in'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'

-- TODO: Need to confirm that input does not have nulls
-- TODO: Need to send length of SC if appropriate?
return function (
  in_qtype,

  optargs
  )
  -- seed values are referred from AB repo seed values
  local seed1 = 961748941
  local seed2 = 982451653
  local seed  = 128356055 
  local op_qtype = "I8"
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( optargs.seed1 ) then seed1 = optargs.seed1 end
    if ( optargs.seed2 ) then seed2 = optargs.seed2 end
    if ( optargs.seed  ) then seed  = optargs.seed  end
    if ( optargs.op_qtype) then op_qtype = optargs.op_qtype end
  end

  -- TODO Ideally test with SV as well
  assert(is_in(in_qtype, {"I1", "I2", "I4", "I8", "F4", "F8", "SC"}))
  assert(is_in(op_qtype, {"I1", "I2", "I4", "I8"}))
  assert(type(seed1) == "number")
  assert(type(seed2) == "number")
  assert(type(seed ) == "number")

  local  in_ctype = qconsts.qtypes[in_qtype].ctype
  local out_ctype = qconsts.qtypes[out_qtype].ctype
  subs.fn = "hash" .. in_qtype .. "_" .. out_qtype
  subs.in_qtype  = in_qtype
  subs.out_qtype = out_qtype
  subs.in_ctype  = in_ctype
  subs.out_ctype = out_ctype
  local args_ctype = "SPOOKY_STATE"
  local cst_args_as = "SPOOKY_STATE *"
  local sz_args = ffi.sizeof(args_ctype)
  local args = assert(cmem.new(sz_args), "malloc failed")
  args_ptr = ffi.cast(cst_args_as, args)
  subs.args_ptr = args_ptr
  args_ptr[0].q_is_first = 1;
  args_ptr[0].q_seed1 = seed1
  args_ptr[0].q_seed2 = seed2
  args_ptr[0].q_seed  = seed
  if ( in_qtype == "SC" ) then 
    args_ptr[0].stride = XXXX
  else
    args_ptr[0].stride = ffi.sizeof(in_ctype)
  end
  -- initialization of args in expander


  tmpl = 'hash.tmpl'
  return subs, tmpl
end
