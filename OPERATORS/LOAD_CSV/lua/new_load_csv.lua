-- This version supports chunking in load_csv
local Dictionary    = require 'Q/UTILS/lua/dictionary'
local err           = require 'Q/UTILS/lua/error_code'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local lVector       = require 'Q/RUNTIME/lua/lVector'
local qc            = require 'Q/UTILS/lua/q_core'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local validate_meta = require "Q/OPERATORS/LOAD_CSV/lua/validate_meta"
local process_opt_args = require "Q/OPERATORS/LOAD_CSV/lua/process_opt_args"
local init_buffers  = require "Q/OPERATORS/LOAD_CSV/lua/init_buffers"
local load_csv_fast_C  = require "Q/OPERATORS/LOAD_CSV/lua/load_csv_fast_C"
local update_out_buf   = require "Q/OPERATORS/LOAD_CSV/lua/update_out_buf"
local flush_bufs    = require "Q/OPERATORS/LOAD_CSV/lua/flush_bufs"
local get_ptr	    = require 'Q/UTILS/lua/get_ptr'
local cmem          = require 'libcmem'
local hash          = require 'Q/OPERATORS/HASH/lua/hash'
 --======================================
local function load_csv(
  infile,   -- input file to read (string)
  M,  -- metadata (table)
  opt_args
  )
  assert( (infile) and (qc.file_exists(infile)), err.INPUT_FILE_NOT_FOUND)
  assert(tonumber(qc.get_file_size(infile)) > 0, err.INPUT_FILE_EMPTY)
  validate_meta(M) 
  local is_hdr = process_opt_args(opt_args)
  --=======================================
  local chunk_idx = 0
  local file_offset = ffi.cast("uint64_t *", 
    get_ptr(cmem.new(1*ffi.sizeof("uint64_t"))))
  file_offset[0] = 0
  local num_rows_read = ffi.cast("uint64_t *", 
    get_ptr(cmem.new(1*ffi.sizeof("uint64_t"))))
  --=======================================
  lgens = {}
  for _, v in pairs(M) do 
    local name = v.name
    local function lgen(chunk_num)
    assert(chunk_num == chunk_idx)
    local start_time = qc.RDTSC()
    num_rows_read[0] = 0
    local all_done  = load_csv_fast_C(M, infile, is_hdr,
      file_offset, num_rows_read)
    record_time(start_time, "load_csv_fast")
    if  ( num_rows_read == 0 ) then
      return 0, nil, nil
    end
    chunk_idx = chunk_idx + 1 
    return len, buf, nn_buf
    lgens[name] = lgen
  end
      --[[
      cols[i]:eov()
      if ( ( M[i].has_nulls ) and ( M[i].num_nulls == 0 ) ) then
        -- Drop the null column, get the nn_file_name from metadata
        local null_file = cols[i]:meta().nn.file_name
        cols[i]:drop_nulls()
        -- assert(qc["delete_file"](null_file),err.INPUT_FILE_NOT_FOUND)
      end
      cols[i]:set_meta("num_nulls", M[i].num_nulls)
      cols_to_return[M[i].name] = cols[i]

  X = ffi.cast("char *", X)
  status = qc.rs_munmap(X, nX)
  assert(status == 0, "Unmap failed")
      --]]
  --==============================================
    local cols_to_return = {} 
    for _, v in pairs(M) do
      cols_to_return[v.name] = lVector(
      {gen = lgen, has_nulls = v.has_nulls, qtype = v.qtype})
      if ( type(v.meaning) == "string" ) then 
        cols_to_return[v.name]:set_meta("__meaning", M[i].meaning)
      end
    end
    return cols_to_return
  end
  --==============================================
end

return require('Q/q_export').export('load_csv', load_csv)
