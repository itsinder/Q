local data_dir      = require('Q/q_export').Q_DATA_DIR
local Dictionary    = require 'Q/UTILS/lua/dictionary'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local lVector       = require 'Q/RUNTIME/lua/lVector'
local plpath        = require 'pl.path'
local plstring      = require 'pl.stringx'
local qc            = require 'Q/UTILS/lua/q_core'
local qconsts       = require 'Q/UTILS/lua/q_consts'

local function load_csv_fast_C(M, infile, is_hdr)
  local nC = #M
  local nR = ffi.malloc(ffi.sizeof("uint64_t"))
  local n_str_for_lua = ffi.malloc(ffi.sizeof("int"))
  n_str_for_lua = ffi.cast("int *", n_str_for_lua)
  n_str_for_lua[0] = 0
  local fldtypes = ffi.malloc(#M * ffi.sizeof("char *"))
  fldtypes = ffi.cast("char **", fldtypes)
  
  local is_load = ffi.malloc(#M * ffi.sizeof("bool"))
  is_load = ffi.cast("bool *", is_load)

  local has_nulls = ffi.malloc(#M * ffi.sizeof("bool"))
  has_nulls = ffi.cast("bool *", has_nulls)  
  
  for i = 1, #M do
    -- TODO Do not hard code 4 below 
    fldtypes[i-1] = ffi.malloc(4 * ffi.sizeof("char"))
    fldtypes[i-1] = ffi.cast("char *", fldtypes[i-1])
    ffi.copy(fldtypes[i-1], M[i].qtype)
    
    is_load[i-1] = M[i].is_load
    
    has_nulls[i-1] = M[i].has_nulls
  end
  
  local num_nulls = ffi.malloc(ffi.sizeof("uint64_t"))
  num_nulls = ffi.cast("uint64_t *", num_nulls)

  local out_files = nil
  local nil_files = nil 

  local sz_str_for_lua = qconsts.sz_str_for_lua

  local str_for_lua = ffi.malloc(sz_str_for_lua)
  str_for_lua = ffi.cast("char *", str_for_lua)
  ffi.copy(str_for_lua, "01234567890123456789012345678901234567890123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ");

  -- call to the load_csv_fast function
  l_data_dir = ffi.malloc(1024) -- FIX 
  ffi.fill(l_data_dir, 1024) -- FIX 
  ffi.copy(l_data_dir, "/home/subramon/local/Q/data/", 28); -- FIX 
  local status = qc["load_csv_fast"](l_data_dir, infile, nC, nR, fldtypes,
  is_hdr, is_load, has_nulls, num_nulls, out_files, nil_files,
  str_for_lua, sz_str_for_lua, n_str_for_lua);
  print("LUA: Done with C ")
  assert(status == 0, "load_csv_fast failed")

  local n = n_str_for_lua[0]
  assert(n > 0)
  str_to_load = ffi.string(str_for_lua, n)
  local T = loadstring(str_to_load)()
  assert(T)
  assert( (type(T) == "table" ), "type of T is not table")
  for i = 1, #T do
    assert( type(T[i]) == "lVector", "type is not lVector")
  end
  
  return T
end

return load_csv_fast_C

