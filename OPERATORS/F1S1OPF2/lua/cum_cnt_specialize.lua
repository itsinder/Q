local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'

return function (
  val_qtype,
  optargs
  )
  local hdr = [[
typedef struct _cum_cnt_<<qtype>>_args {
  <<ctype>> prev_val;
  int64_t prev_cnt; 
} CUM_CNT_<<qtype>>_ARGS;
  ]]
  assert(is_base_qtype(val_qtype))

  --preamble
  local tmpl = 'cum_cnt.tmpl'
  local subs = {}; 
  subs.val_qtype = val_qtype
  subs.val_ctype = qconsts.qtypes[val_qtype].ctype
  --===============
  hdr = string.gsub(hdr,"<<qtype>>", subs.val_qtype)
  hdr = string.gsub(hdr,"<<ctype>>", subs.val_ctype)
  pcall(ffi.cdef, hdr)
  --===============
  -- Set c_mem using info from args
  local arg_type = "CUM_CNT_" .. val_qtype .. "_ARGS"
  local sz_c_mem = ffi.sizeof(arg_type)
  local c_mem = assert(cmem.new(sz_c_mem), "malloc failed")
  local c_mem_ptr = ffi.cast(arg_type .. " *", get_ptr(c_mem))
  c_mem_ptr.prev_cnt  = -1;
  c_mem_ptr.prev_val  = 0;
  subs.c_mem = c_mem
  subs.c_mem_type = arg_type .. " *"
  --===============
  local cnt_qtype = "I8"
  if ( optargs ) then
    assert(type(optargs) == "table")
    if ( optargs.in_nR ) then
      assert(type(optargs.in_nR) == "number")
      assert(optargs.in_nR >= 1 )
      if ( optargs.in_nR <= 127 ) then
        cnt_qtype = "I8"
      elseif ( optargs.in_nR <= 32767 ) then
        cnt_qtype = "I2"
      elseif ( optargs.in_nR <= 2147483647 ) then
        cnt_qtype = "I4"
      end
    else
      if ( optargs.cnt_qtype ) then 
        assert(type(optargs.cnt_qtype) == "string")
        cnt_qtype = optargs.cnt_qtype
        if ( ( cnt_qtype == "I1" ) or ( cnt_qtype == "I2" ) or
             ( cnt_qtype == "I4" ) or ( cnt_qtype == "I8" ) ) then
             -- all is well
        else
          assert(nil, "bad cnt_qtype")
        end
      end
    end
  end
  --===============
  subs.fn = "cum_cnt_" .. val_qtype .. "_" .. cnt_qtype
  subs.cnt_qtype = cnt_qtype
  subs.cnt_ctype = qconsts.qtypes[subs.cnt_qtype].ctype
  subs.c_mem = cmem
  return subs, tmpl
end
