local data_dir      = require('Q/q_export').Q_DATA_DIR
local Dictionary    = require 'Q/UTILS/lua/dictionary'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local lVector       = require 'Q/RUNTIME/lua/lVector'
local qc            = require 'Q/UTILS/lua/q_core'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local plpath        = require 'pl.path'

ffi.cdef([[
       char *strncpy(char *dest, const char *src, size_t n);
       ]]
       )

local function load_csv_fast_C(M, infile, is_hdr)
  local nR = ffi.gc(ffi.cast("uint64_t *", ffi.C.malloc(1*ffi.sizeof("uint64_t"))), ffi.C.free)
  nR[0] = 0
  local nC = #M

  local fldtypes = ffi.gc(
    ffi.C.malloc(nC * ffi.sizeof("char *")), 
    ffi.C.free)
  fldtypes = ffi.cast("char **", fldtypes)
  
  local is_load = ffi.gc(ffi.C.malloc(nC * ffi.sizeof("bool")), ffi.C.free)
  is_load = ffi.cast("bool *", is_load)

  local has_nulls = ffi.gc(ffi.C.malloc(nC * ffi.sizeof("bool")), ffi.C.free)
  has_nulls = ffi.cast("bool *", has_nulls)  
  
  local num_nulls = ffi.gc(ffi.C.malloc(nC * ffi.sizeof("uint64_t")), ffi.C.free)
  num_nulls = ffi.cast("uint64_t *", num_nulls)

  local fld_name_width = 4 -- TODO Undo this hard coiding
  for i = 1, nC do
    fldtypes[i-1]  = ffi.gc(
      ffi.C.malloc(fld_name_width * ffi.sizeof("char")), ffi.C.free)
    --[[
    fldtypes[i-1]  = ffi.cast("char *", fldtypes[i-1])
    ffi.C.strncpy(fldtypes[i-1], M[i].qtype, ffi.C.strlen(M[i].qtype))
    --]]
    ffi.copy(fldtypes[i-1], M[i].qtype)
    is_load[i-1]   = M[i].is_load
    has_nulls[i-1] = M[i].has_nulls
  end

  local out_files = nil
  local nil_files = nil 

  local sz_str_for_lua = qconsts.sz_str_for_lua

  local str_for_lua = ffi.gc(ffi.C.malloc(sz_str_for_lua * ffi.sizeof("char")), ffi.C.free)
  str_for_lua = ffi.cast("char *", str_for_lua)
  ffi.fill(str_for_lua, sz_str_for_lua)

  local n_str_for_lua = ffi.gc(ffi.C.malloc(1 * ffi.sizeof("int32_t")), ffi.C.free)
  n_str_for_lua = ffi.cast("int *", n_str_for_lua)
  n_str_for_lua[0] = 0

  assert(plpath.isdir(data_dir))
  assert(plpath.isfile(infile))

  -- assert(nil, "premature") -- call to the load_csv_fast function
  local status = qc["load_csv_fast"](data_dir, infile, nC, nR, fldtypes,
  is_hdr, is_load, has_nulls, num_nulls, out_files, nil_files,
  str_for_lua, sz_str_for_lua, n_str_for_lua);
  -- assert(nil, "Premature termination")
  assert(status == 0, "load_csv_fast failed")

  local n = n_str_for_lua[0]
  assert(n > 0)
  local str_to_load = ffi.string(str_for_lua, n)
  local T = loadstring(str_to_load)()
  assert(T)
  assert( (type(T) == "table" ), "type of T is not table")
  for i = 1, #T do
    assert( type(T[i]) == "lVector", "type is not lVector")
  end
  
  return T
end

return load_csv_fast_C

