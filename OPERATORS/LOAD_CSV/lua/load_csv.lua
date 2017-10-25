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

local function get_field_widths(field)
  local field_size = nil
  local max_txt_width = 0
  if field.qtype == "SV" then
    -- times 2 to deal with escaping
    max_txt_width = 2 * assert(field.max_width)
  elseif field.qtype == "SC" then
    field_size = field.width -- set only for SC
    -- times 2 to deal with escaping
    max_txt_width = 2 * assert(field.width)
  else
    max_txt_width = assert(qconsts.qtypes[field.qtype].max_txt_width)
  end
  return field_size, max_txt_width
end

local function get_buffer_for_type()

end

local initialize_buffers = function(M)
  local num_cols = #M
  local cols = {} -- cols[i] is Column used for column i
  local dicts = {} -- dicts[i] is di ctionary used for column i
  local out_buf_array = {}
  local out_buf_nn_array = {}
  local max_txt_width = 0
  local field_size 
  --TODO Krushnakant I dont understand what this statement means
  -- If chunk_size is not multiple of num_cols then
  -- the total buffer size (sum of all column buffer size) will be larger than the chunk_size by margin
  local out_buf_size = math.ceil(qconsts.chunk_size / num_cols)
  local nn_buf_size = math.ceil(out_buf_size/8)
  -- This loop does following things
  -- (1) calculate max_txt_width
  -- (2) create Column for each is_load column
  -- (3) create Dictionary for each is_load SV column
  -- (4) create output buffer for each is_load column
  for col_idx = 1, num_cols do
    if M[col_idx].is_load then
      field_size, max_txt_width = get_field_widths(M[col_idx])
      cols[col_idx] = lVector{
        qtype=M[col_idx].qtype,
        gen = true,
        width=field_size,
        is_memo=true,
        has_nulls=M[col_idx].has_nulls}
      M[col_idx].num_nulls = 0
      if M[col_idx].qtype == "SV" then
        dicts[col_idx] = assert(Dictionary(M[col_idx].dict),
        "error creating dictionary " .. M[col_idx].dict .. " for " .. M[col_idx].name)
        cols[col_idx]:set_meta("dir", dicts[col_idx])
      end
      if ( M[col_idx].qtype ~= "SC" ) then
        field_size = qconsts.qtypes[M[col_idx].qtype].width
      end
      -- Allocate memory for output buf and add to pool
      out_buf_array[#out_buf_array + 1] = ffi.malloc(out_buf_size * field_size)
      ffi.fill(out_buf_array[col_idx], out_buf_size * field_size, 0)
      out_buf_nn_array[#out_buf_nn_array + 1] = ffi.malloc(nn_buf_size)
      ffi.fill(out_buf_nn_array[col_idx], nn_buf_size, 0)
    end
  end
  assert(max_txt_width > 0)
  return cols, dicts, out_buf_array, out_buf_nn_array, out_buf_size, nn_buf_size, max_txt_width
end

local function check_SC_or_SV_present(M)
  local no_of_cols = #M
  for itr =1, no_of_cols do
    if(M[itr].qtype == "SC" or M[itr].qtype == "SV" )then
      return true
    end
  end
  return false
end

local function load_csv_fast_C(M, infile, is_hdr)
  local nC = #M
  local nR = ffi.malloc(ffi.sizeof("uint64_t"))
  local fldtypes = ffi.malloc(#M * ffi.sizeof("char *"))
  fldtypes = ffi.cast("char **", fldtypes)
  
  local is_load = ffi.malloc(#M * ffi.sizeof("bool"))
  is_load = ffi.cast("bool *", is_load)

  local has_nulls = ffi.malloc(#M * ffi.sizeof("bool"))
  has_nulls = ffi.cast("bool *", has_nulls)  
  
  for i = 1, #M do
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

  -- call to the load_csv_fast function
  local status = qc["load_csv_fast"](data_dir, infile, nC, nR, fldtypes,
  is_hdr, is_load, has_nulls, num_nulls, out_files, nil_files,
  str_for_lua, sz_str_for_lua)
  assert(status == 0, "load_csv_fast failed")
  
  local vector_string = ffi.string(str_for_lua)
  assert(( vector_string ) and ( vector_string ~= "" ), "load_csv_fast returned a null string" )

  local T = loadstring(vector_string)()

  assert( (type(T) == "table" ), "type of T is not table")
  for i = 1, #T do
    assert( type(T[i]) == "lVector", "type is not lVector")
  end
  
  return T
end

local function load_csv(
  infile,   -- input file to read (string)
  M,  -- metadata (table)
  opt_args
  )
  assert( infile ~= nil and plpath.isfile(infile),err.INPUT_FILE_NOT_FOUND)
  assert(plpath.getsize(infile) > 0, err.INPUT_FILE_EMPTY)
  -- Validate Metadata
  validate_meta(M)
  
  -- opt_args default values
  -- use_accelerator is set to true
  -- is_hdr is set to false
  local use_accelerator = true
  local is_hdr = false
  if opt_args then
    assert(type(opt_args) == "table", "opt_args must be of type table")
    if opt_args["use_accelerator"] ~= nil then
      assert(type(opt_args["use_accelerator"]) == "boolean", "type of use_accelerator is not boolean")
      use_accelerator = opt_args["use_accelerator"]
    end
    if opt_args["is_hdr"] ~= nil then
      assert(type(opt_args["is_hdr"]) == "boolean", "type of is_hdr is not boolean")
      is_hdr = opt_args["is_hdr"]
    end
  end
  -- assert(M.qtype ~= "B1" and use_accelerator ~= false," qtype B1 not supported in load_csv lua")
  
  local cols_to_return

  -- if no SC or SV then call load_csv_fast C function
  if (not check_SC_or_SV_present(M) and use_accelerator )then
    cols_to_return = load_csv_fast_C(M, infile, is_hdr)
  else
    -- Initialize Buffers
    local cols, dicts, out_buf_array, out_buf_nn_array, out_buf_size, nn_buf_size, max_txt_width = initialize_buffers(M)
    -- Memory map the input file
    local f_map = ffi.gc(qc.f_mmap(infile, false), qc.f_munmap)
    assert(f_map.status == 0 , err.MMAP_FAILED)
    local X = ffi.cast("char *", f_map.map_addr)
    local nX = tonumber(f_map.map_len)
    assert(nX > 0, err.FILE_EMPTY)
    
    local x_idx = 0
    local in_buf  = ffi.malloc(max_txt_width)
    local row_idx = 1
    local col_idx = 1
    local num_in_out_buf = 0
    local num_cols = #M

    while true do
      local is_last_col = false
      if ( col_idx == num_cols ) then
        is_last_col = true;
      end
      local field_size = assert(qconsts.qtypes[M[col_idx].qtype].width)
      if ( M[col_idx].qtype == "SC" ) then
        field_size = M[col_idx].width
      end
      ffi.fill(in_buf, max_txt_width, 0) -- always init to 0
      if ( is_hdr and row_idx == 1)then
        x_idx = tonumber(
        qc.get_cell(X, nX, x_idx, is_last_col, in_buf, max_txt_width))
        assert(x_idx > 0 , err.INVALID_INDEX_ERROR)
        col_idx = col_idx + 1
        
        if ( is_last_col ) then
          row_idx = row_idx + 1
          col_idx = 1
        end
      else
        x_idx = tonumber(
        qc.get_cell(X, nX, x_idx, is_last_col, in_buf, max_txt_width))
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
            local temp_out_buf = ffi.cast("char *", out_buf_array[col_idx]) + (num_in_out_buf * field_size)
            mk_out_buf(in_buf, M[col_idx], dicts[col_idx], temp_out_buf)

            -- Update nn_out_buf
            local widx = math.floor(num_in_out_buf / 8)
            local bidx = (num_in_out_buf % 8)
            local temp_nn_out_buf = ffi.cast("char *", out_buf_nn_array[col_idx])
            qc.set_bit(temp_nn_out_buf + widx, bidx)

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
              -- write to column
              cols[i]:put_chunk(out_buf_array[i], out_buf_nn_array[i], out_buf_size)

              -- Initialize buffer to 0
              ffi.fill(out_buf_array[i], out_buf_size)
              ffi.fill(out_buf_nn_array[i], nn_buf_size)
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
        cols[i]:put_chunk(out_buf_array[i], out_buf_nn_array[i], num_in_out_buf)
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
  end
  return cols_to_return
end

return require('Q/q_export').export('load_csv', load_csv)