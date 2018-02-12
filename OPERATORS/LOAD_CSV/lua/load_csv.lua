local data_dir      = require('Q/q_export').Q_DATA_DIR
local Dictionary    = require 'Q/UTILS/lua/dictionary'
local err           = require 'Q/UTILS/lua/error_code'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local lVector       = require 'Q/RUNTIME/lua/lVector'
local plpath        = require 'pl.path'
local plstring      = require 'pl.stringx'
local qc            = require 'Q/UTILS/lua/q_core'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local validate_meta = require "Q/OPERATORS/LOAD_CSV/lua/validate_meta"
local is_accelerate = require "Q/OPERATORS/LOAD_CSV/lua/is_accelerate"
local process_opt_args = require "Q/OPERATORS/LOAD_CSV/lua/process_opt_args"
local init_buffers  = require "Q/OPERATORS/LOAD_CSV/lua/init_buffers"
local load_csv_fast_C  = require "Q/OPERATORS/LOAD_CSV/lua/load_csv_fast_C"
local plfile     = require 'pl.file'

local function mk_out_buf(
  in_buf,
  m,  -- m is meta data for field
  d,  -- d is dictiomnary for field
  out_buf
  )
  local status = 0
  local in_buf_len = assert(tonumber(ffi.C.strlen(in_buf)))
  if m.qtype == "SV" then
    assert(in_buf_len <= m.max_width, err.STRING_TOO_LONG)
    local stridx = nil
    if ( in_buf_len == 0 ) then
      stridx = 0
    else
      if ( m.add ) then
        stridx = d:add(ffi.string(in_buf))
      else
        stridx = d:get_index_by_string(ffi.string(in_buf))
      end
    end
    assert(stridx, "dictionary does not have string " .. ffi.string(in_buf))
    ffi.cast(qconsts.qtypes.I4.ctype .. " *", out_buf)[0] = stridx
  elseif m.qtype == "SC" then
    assert(in_buf_len <= m.width, err.STRING_TOO_LONG)
    ffi.copy(out_buf, in_buf, in_buf_len)
  elseif is_base_qtype(m.qtype) then
    local converter = assert(qconsts.qtypes[m.qtype]["txt_to_ctype"])
    local ctype     = assert(qconsts.qtypes[m.qtype]["ctype"])
    local casted    = ffi.cast(ctype .. " *", out_buf)
    status = qc[converter](in_buf, casted)
  elseif m.qtype == "B1" then  -- IMPROVE THIS CODE
    local casted = ffi.cast("uint8_t *", out_buf)
    if ( ffi.string(in_buf) == "1" ) then
      casted[0] = 255
    elseif ( ffi.string(in_buf) == "0" ) then
      casted[0] = 0
    else
      status = 1
    end
  end
  assert(status == 0, err.INVALID_DATA_ERROR .. m.qtype)
end

local function load_csv(
  infile,   -- input file to read (string)
  M,  -- metadata (table)
  opt_args
  )
  assert( infile ~= nil and plpath.isfile(infile),err.INPUT_FILE_NOT_FOUND)
  assert(plpath.getsize(infile) > 0, err.INPUT_FILE_EMPTY)

  validate_meta(M) -- Validate Metadata
  local use_accelerator, is_hdr = process_opt_args(opt_args)
  
  local cols_to_return -- this is what we return 

  -- use optimized C code if okay to do so 
  local l_is_accelerate = is_accelerate(M) 
  if ( l_is_accelerate and use_accelerator )then
    cols_to_return = load_csv_fast_C(M, infile, is_hdr)
    return cols_to_return
  end
  -- Initialize Buffers
  local cols, dicts, out_bufs, nn_out_bufs = init_buffers(M)
  -- Memory map the input file
  local f_map = ffi.gc(qc.f_mmap(infile, false), qc.f_munmap)
  assert(f_map.status == 0 , err.MMAP_FAILED)
  local X = ffi.cast("char *", f_map.map_addr)
  local nX = tonumber(f_map.map_len)
  assert(nX > 0, err.FILE_EMPTY)
  --===================================================
  
  local x_idx = 0
  sz_in_buf = 2048 -- TODO Undo hard coding 
  local in_buf  = assert(ffi.gc(ffi.C.malloc(sz_in_buf)), ffi.C.free)
  local row_idx = 1
  local col_idx = 1
  local num_in_out_buf = 0
  local num_cols = #M

  while true do
    local is_last_col = false
    if ( col_idx == num_cols ) then
      is_last_col = true;
    end
    ffi.fill(in_buf, sz_in_buf) -- always init to 0
    if ( ( is_hdr ) and ( row_idx == 1 ) ) then
      -- Process header line
      x_idx = qc.get_cell(X, nX, x_idx, is_last_col, in_buf, max_txt_width)
      assert(x_idx > 0 , err.INVALID_INDEX_ERROR)
      col_idx = col_idx + 1
      if ( is_last_col ) then
        row_idx = row_idx + 1
        col_idx = 1
      end
    else -- Not header line. Real work starts here
      x_idx = qc.get_cell(X, nX, x_idx, is_last_col, in_buf, max_txt_width)
      assert(x_idx > 0 , err.INVALID_INDEX_ERROR)
      if ( M[col_idx].is_load ) then
        local str = plstring.strip(ffi.string(in_buf))
        local is_null = (str == "")
        -- Process null value case
        if is_null then
          assert(M[col_idx].has_nulls, err.NULL_IN_NOT_NULL_FIELD)
          M[col_idx].num_nulls = M[col_idx].num_nulls + 1
        else
          -- Update out_buf
          local temp_out_buf = ffi.cast("char *", out_bufs[col_idx]) + (num_in_out_buf * field_size)
          mk_out_buf(in_buf, M[col_idx], dicts[col_idx], temp_out_buf)

          -- Update nn_out_buf
          local temp_nn_out_buf = ffi.cast(qconsts.qtypes.B1.ctype .. " *", nn_out_bufs[col_idx])
          qc.set_bit_u64(temp_nn_out_buf, num_in_out_buf, 1)

        end
      end
      --=======================================
      if ( is_last_col ) then
        row_idx = row_idx + 1
        col_idx = 1;
        -- increment out_buf count
        num_in_out_buf = num_in_out_buf + 1
        -- Check number of elements in all out_buf, if all buffers are full, write it to column
        if ( num_in_out_buf == out_buf_size ) then
          print("Intermediate Flush ..")
          for i = 1, num_cols do
            if ( M[i].is_load ) then 
            -- write to column
            cols[i]:put_chunk(out_bufs[i], nn_out_bufs[i], out_buf_size)

            -- Initialize buffer to 0
            ffi.fill(out_bufs[i], out_buf_size)
            ffi.fill(nn_out_bufs[i], nn_buf_size)
            end
          end
          num_in_out_buf = 0
        end
      else
        col_idx = col_idx + 1
      end
      assert(x_idx <= nX)
      if  (x_idx >= nX) then break end
    end
  end
  assert(x_idx == nX, err.DID_NOT_END_PROPERLY)
  assert(col_idx == 1, err.BAD_NUMBER_COLUMNS)

  if ( num_in_out_buf > 0 ) then
    print("Flushing values to all columns.."..tostring(num_in_out_buf))
    for i = 1, num_cols do
      if ( M[i].is_load ) then 
        cols[i]:put_chunk(out_bufs[i], nn_out_bufs[i], num_in_out_buf)
      end
    end
  end
  --======================================
  --print("Preparing return columns")
  cols_to_return = {}
  local rc_idx = 1
  for i = 1, #M do
    if ( M[i].is_load ) then
      cols[i]:eov()
      if ( ( M[i].has_nulls ) and ( M[i].num_nulls == 0 ) ) then
        -- Drop the null column, get the nn_file_name from metadata
        local null_file = cols[i]:meta().nn.file_name
        cols[i]:drop_nulls()
        -- assert(plfile.delete(null_file),err.INPUT_FILE_NOT_FOUND)
      end
      cols_to_return[rc_idx] = cols[i]
      cols_to_return[rc_idx]:set_meta("num_nulls", M[i].num_nulls)
      rc_idx = rc_idx + 1
    end
  end
  return cols_to_return
end

return require('Q/q_export').export('load_csv', load_csv)
