local qconsts = require 'Q/UTILS/lua/q_consts'
local validate_meta = require "Q/OPERATORS/LOAD_CSV/lua/validate_meta"
local err           = require 'Q/UTILS/lua/error_code'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local ffi           = require 'Q/UTILS/lua/q_ffi'
local qc            = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'

local Dictionary = require 'Q/UTILS/lua/dictionary'
local Column     = require 'Q/experimental/lua-515/c_modules/lVector'
local plstring   = require 'pl.stringx'
local plfile     = require 'pl.file'

local print_csv = require 'Q/OPERATORS/PRINT/lua/print_csv'

local function mk_out_buf(
  in_buf, 
  m,  -- m is meta data for field 
  d,  -- d is dictiomnary for field 
  out_buf,
  err_msg
)
    local in_buf_len = assert( tonumber(ffi.C.strlen(in_buf)))

    if m.qtype == "SV" then 
      assert(in_buf_len <= m.max_width, err_msg .. err.STRING_TOO_LONG)
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
      assert(stridx,
      err_msg .. "dictionary does not have string " .. ffi.string(in_buf))
      ffi.cast("int32_t *", out_buf)[0] = stridx
    end   
    --=======================================
    if m.qtype == "SC" then 
      assert(in_buf_len <= m.width, err_msg .. err.STRING_TOO_LONG)
      ffi.copy(out_buf, in_buf, in_buf_len)
    end
    --=======================================
    local converter = assert(qconsts.qtypes[m.qtype]["txt_to_ctype"])
    local ctype     = assert(qconsts.qtypes[m.qtype]["ctype"])
    local status = 0
    local casted = ffi.cast(ctype .. " *", out_buf)
    --=====================================
    if ( is_base_qtype(m.qtype) ) then 
      status = qc[converter](in_buf, casted) 
    end
    if m.qtype == "B1" then  -- IMPROVE THIS CODE 
      local casted = ffi.cast("uint8_t *", out_buf)
      if ( ffi.string(in_buf) == "1" ) then 
        casted[0] = 255 
      else if ( ffi.string(in_buf) == "0" ) then 
        casted[0] = 0
      else 
        status = 1
      end
    end
  end
  assert(status == 0, err.INVALID_DATA_ERROR .. m.qtype)
end

load_csv = function ( 
  infile,   -- input file to read (string)
  M,  -- metadata (table)
  global_settings -- TODO unused for now
)
    local plpath = require 'pl.path'
    local cols = {} -- cols[i] is Column used for column i 
    local dicts = {} -- dicts[i] is di ctionary used for column i
    assert( infile ~= nil and plpath.isfile(infile),err.INPUT_FILE_NOT_FOUND)
    assert(plpath.getsize(infile) > 0, err.INPUT_FILE_EMPTY)
    -- Sri: Think this isn't needed; such stuff shoul be ensured by library loading; trust our own :) ?
    --assert( _G["Q_DATA_DIR"] ~= nil and plpath.isdir(_G["Q_DATA_DIR"]), err.Q_DATA_DIR_NOT_FOUND)
    --assert( _G["Q_META_DATA_DIR"] ~= nil and plpath.isdir(_G["Q_META_DATA_DIR"]), err.Q_META_DATA_DIR_NOT_FOUND)
    validate_meta(M)

    local max_txt_width = 0
    -- Create out_buf_pool, pool size will be number of columns,
    -- each buffer will be of size = chunk_size/num_col
    local out_buf_array = {}
    local out_buf_nn_array = {}
    local num_cols = #M
    -- If chunk_size is not multiple of num_cols then 
    -- the total of all out_buf size will be larger than chunk_size by margin     
    local out_buf_size = math.ceil(qconsts.chunk_size / num_cols) 
    local nn_buf_size = math.ceil(out_buf_size/64) * 8
    
    -- This loop does following things
    -- (1) calculate max_txt_width 
    -- (2) create Column for each is_load column 
    -- (3) create Dictionary for each is_load SV column
    -- (4) create output buffer for each is_load column
    
    for col_idx = 1, num_cols do 
      if M[col_idx].is_load then 
        local field_size = nil
        local fld_max_txt_width = 0
        if M[col_idx].qtype == "SV" then
          -- times 2 to deal with escaping
          fld_max_txt_width = 2 * assert(M[col_idx].max_width)
        elseif M[col_idx].qtype == "SC" then
          field_size = M[col_idx].width -- set only for SC
          -- times 2 to deal with escaping
          fld_max_txt_width = 2 * assert(M[col_idx].width)
        else
          fld_max_txt_width = assert(qconsts.qtypes[M[col_idx].qtype].max_txt_width)
        end
        max_txt_width = ( fld_max_txt_width > max_txt_width ) 
        and fld_max_txt_width or max_txt_width 
        --==============================
        cols[col_idx] = Column{
          qtype=M[col_idx].qtype,
          gen = true,
          width=field_size,
          has_nulls=M[col_idx].has_nulls }
        --==============================
        M[col_idx].num_nulls = 0
        --==============================
        if M[col_idx].qtype == "SV" then
          dicts[col_idx] = assert(Dictionary(M[col_idx].dict), 
          "error creating dictionary " .. M[col_idx].dict .. " for " .. M[col_idx].name)
          cols[col_idx]:set_meta("dir",dicts[col_idx])
        end 
        
        -- Get field size
        if ( M[col_idx].qtype ~= "SC" ) then
          field_size = qconsts.qtypes[M[col_idx].qtype].width
        end

        -- Allocate memory for output buf and add to pool
        table.insert(out_buf_array, cmem.new(out_buf_size * field_size))

        -- Allocate memory for nn buf and add to pool
        table.insert(out_buf_nn_array, cmem.new(nn_buf_size))

        -- Initialize both buffers to 0
        ffi.fill(out_buf_array[col_idx], out_buf_size * field_size, 0)
        ffi.fill(out_buf_nn_array[col_idx], nn_buf_size, 0)
      end    
    end
    assert(max_txt_width > 0)
    
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
      -- create an error message that might be needed
      local err_msg = "error in row " .. row_idx .. " column " .. col_idx
      x_idx = tonumber(
      qc.get_cell(X, nX, x_idx, is_last_col, in_buf, max_txt_width))
      assert(x_idx > 0 , err_msg .. err.INVALID_INDEX_ERROR)
      if ( M[col_idx].is_load ) then 
        local str = plstring.strip(ffi.string(in_buf))
        local is_null = (str == "")
        -- Process null value case
        if is_null then 
          assert(M[col_idx].has_nulls, err_msg .. err.NULL_IN_NOT_NULL_FIELD) 
          M[col_idx].num_nulls = M[col_idx].num_nulls + 1
        else
          local temp_out_buf = ffi.cast("char *", out_buf_array[col_idx]) + (num_in_out_buf * field_size)
          
          local temp_nn_out_buf = ffi.cast("char *", out_buf_nn_array[col_idx])
          local index = math.floor((num_in_out_buf)/64)
          temp_nn_out_buf[index] = temp_nn_out_buf[index] + math.pow(2, num_in_out_buf)
          
          mk_out_buf(in_buf, M[col_idx], dicts[col_idx], temp_out_buf, err_msg)            
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
    assert(x_idx == nX, err.DID_NOT_END_PROPERLY)
    assert(col_idx == 1, err.BAD_NUMBER_COLUMNS)
    
    if ( num_in_out_buf > 0 ) then
      print("Flushing values to all columns.."..tostring(num_in_out_buf))
      for i = 1, num_cols do
        cols[i]:put_chunk(out_buf_array[i], out_buf_nn_array[i], num_in_out_buf)
        ffi.fill(out_buf_array[i], out_buf_size)
        ffi.fill(out_buf_nn_array[i], nn_buf_size)           
        
        -- Set buffer to nil
        out_buf_array[i] = nil
        out_buf_nn_array[i] = nil
      end
    end      
    out_buf_array = nil
    out_buf_nn_array = nil
    --======================================
    --print("Preparing return columns")
    local cols_to_return = {} 
    local rc_idx = 1
    for i = 1, #M do
      if ( M[i].is_load ) then 
        cols[i]:eov()
        if ( ( M[i].has_nulls ) and ( M[i].num_nulls == 0 ) ) then
          -- TODO drop the null column. Indrajeet to provide
          --local null_file = require('Q/q_export').Q_DATA_DIR .. "/_" .. M[i].name .. "_nn"
          --assert(plfile.delete(null_file),err.INPUT_FILE_NOT_FOUND)
        end
        cols_to_return[rc_idx] = cols[i]
        cols_to_return[rc_idx]:set_meta("num_nulls", M[i].num_nulls)
        rc_idx = rc_idx + 1
      end
    end
    return cols_to_return
end

return require('Q/q_export').export('load_csv', load_csv)
