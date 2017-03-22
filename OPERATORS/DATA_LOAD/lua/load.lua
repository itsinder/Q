-- RS Delete this line - taken care of by LUA_INIT set up
package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
 
require "validate_meta"
local Dictionary = require 'dictionary'
local Column = require 'Column'
--RS Use extract_fn_proto for txt_to_xxxx and so on
--RS Also, you don;t need xxx_to_txt here. You need it in print. Delete
--RS Don't have stuff you do not need. DO you need FILE> Do you need fopen?
--RS and so on....
local ffi = require "ffi"
ffi.cdef([[
  void * malloc(size_t size);
  void free(void *ptr);
  extern size_t get_cell(char *X, size_t nX, size_t xidx, bool is_last_col, char *buf, size_t bufsz);
  
  int txt_to_I1(const char *X, int base, int8_t *ptr_out);
  int txt_to_I2(const char *X, int base, int16_t *ptr_out);
  int txt_to_I4(const char *X, int base, int32_t *ptr_out);
  int txt_to_I8(const char *X, int base, int64_t *ptr_out);
  int txt_to_F4(const char *X, float *ptr_out);
  int txt_to_F8(const char *X, double *ptr_out);
  int txt_to_SC(const char *X, char *out, size_t sz_out);

]])
-- ----------------
-- load( "CSV file to load", "meta data", "Global Metadata")
-- Loads the CSV file and stores in the Q internal format
--
-- returns : table containing list of Columns for each column defined in metadata.
--           If any error was encountered during load operation then will have
--           asserted out
-- ----------------
-- RS Use compile_so to create load_csv.so
local c = ffi.load("load_csv.so")


function load_csv( 
  csv_file_path, 
  M,  -- metadata
  load_global_settings
  )
    local pl = require 'pl'
    assert(pl.path.isdir(_G["Q_DATA_DIR"]))
    assert(pl.path.isdir(_G["Q_META_DATA_DIR"]))
    assert(type(_G["Q_DICTIONARIES"]) == "table")
    local cols = {} -- cols[i] is Column used for column i 
    local dicts = {} -- dicts[i] is di ctionary used for column i

    assert(pl.path.isfile(csv_file_path), "input file not found")
    assert(pl.path.getsize(csv_file_path) > 0, "input file empty")
    assert(pl.path.isdir(_G["Q_DATA_DIR"]), "directory not found -- Q_DATA_DIR")
    assert(pl.path.isdir(_G["Q_META_DATA_DIR"]), "directory not found -- Q_META_DATA_DIR")
    validate_meta(M)

    -- In this loop (1) calculate max_txt_width (2) create Column for each
    -- is_load column (3) create Dictionary for each is_load SV column
    local max_txt_width = 0
    for i = 1, #M do 
      if M[i].is_load then 
        -- Update max_width
        local fld_max_txt_width = 0
        if M[i].qtype == "SV" then
          -- times 2 to deal with escaping
          fld_max_txt_width = 2 * assert(M[i].max_width)
        elseif M[i].qtype == "SC" then
          -- times 2 to deal with escaping
          fld_max_txt_width = 2 * assert(M[i].width)
        else
          fld_max_txt_width = assert(g_qtypes[M[i].qtype].max_txt_width)
        end
        max_width = ( fld_max_txt_width > max_width ) 
          and fld_max_txt_width or max_width 
          --==============================
        cols[i] = Column{
          field_type=M[i].qtype, 
          fld_width, filename= _G["Q_DATA_DIR"] .. "/_" .. M[i].name,
          write_vector=true,
          nn=M[i].has_nulls }
        --==============================
        M[i].num_nulls = 0
        --==============================
        if M[i].qtype == "SV" then
          dicts[i] = assert(Dictionary(M[i].name), 
          "error with dictionary for " .. M[i].name)
        end 
      end    
    end
    assert(max_txt_width > 0)
    --===========================
    f_map = ffi.gc( c.f_mmap(csv_file_path, false), c.f_munmap)
    assert(f_map.status == 0 , "Mmap failed")
    local X = ffi.cast("char *", f_map.ptr_mmapped_file)
    local nX = tonumber(f_map.ptr_file_size)
    assert(nX > 0, "File cannot be empty")

    local x_idx = 0
    local out_buf_sz = 1024 -- TODO FIX 
    local in_buf  = ffi.gc(c.malloc(max_width), c.free)
    local out_buf = ffi.gc(c.malloc(out_buf_sz), c.free)
    local is_nn   = ffi.gc(c.malloc(1), c.free)
    local ncols = #M
    local row_idx = 1
    local col_idx = 1

    while true do
      local is_last_col
      if ( col_idx == ncols ) then
        is_last_col = true;
      else
        is_last_col = false;
      end
      ffi.C.memset(out_buf, 0, out_buf_sz) -- always init to 0
      ffi.C.memset(in_buf, 0, max_width) -- always init to 0
      ffi.C.memset(is_nn, 0, 1) -- assume null
      -- create an error message that might be needed
      local err_loc = "error in row " .. row_idx .. " column " .. col_idx
      x_idx = tonumber(
      c.get_cell(X, nX, x_idx, is_last_col, in_buf, max_width))
      assert(x_idx > 0 , err_loc)
      -- print(row_idx, col_idx, ffi.string(buf))
      local in_buf_len = assert(string.len(ffi.string(in_buf)))
      -- Process null value case
      if in_buf_len == 0 then 
        assert(M[col_idx].has_nulls, 
        err_loc ..  "Null value found in not null field " ) 
        M[i].num_nulls = M[i].num_nulls + 1
      else 
        ffi.C.memset(is_nn, 1, 1)
        local qtype = M[col_idx].qtype
        if qtype == "SV" then 
          assert(in_buf_len > g_max_width_SV, err_loc .. "string too long ")
          local stridx = 0
          if ( M[i].add ) then
            stridx = dict[i].add(in_buf)
          else
            stridx = dict[i].get_index_by_string(in_buf)
          end
          assert(stridx > 0, 
            err_loc .. "dictionary does not have string " .. in_buf)
          ffi.copy(out_buf, stridx)
          end   
        end
        if qtype == "SC" then 
          assert(in_buf_len > M[i].width, err_loc .. "string too long ")
        end
        local function_name = g_qtypes[qtype]["txt_to_ctype"]
        -- for fixed size string pass the size of string data also
        local status = 0
        if qtype == "SC" then
          status = c[function_name](buf, out_buf, out_buf_sz)
        elseif qtype == "I1" or qtype == "I2" or qtype == "I4" or qtype == "I8" or qtype == "SV" then
          -- For now second parameter , base is 10 only
          status = c[function_name](buf, 10, out_buf)
        elseif qtype == "F4" or qtype == "F8"  then 
          status = c[function_name](buf, out_buf)
        else 
          assert(nil, err_loc .. "Data type" .. qtype .. " Not supported ")
        end
        assert( status == 0 , err_loc .. "Invalid data found")
      end   
      column_list[col_idx]:put_chunk(1, out_buf, is_nn)

      if ( is_last_col ) then
        row_idx = row_idx + 1
        col_idx = 1;
      else
        col_idx = col_idx + 1 
      end
      assert(x_idx <= nX) 
    end
    assert(col_idx == num_cols, "bad number of columns on last line")
    --======================================
    for i = 1, #M do
      if ( M[i].is_load ) then assert(cols[i]:eov()) end
    end
    --=============================
    local cols_to_return = {} 
    local rc_idx = 0
    for i = 1, #M do
      if ( M[i].is_load ) then 
        cols_to_return[rc_idx] = cols[i]
        cols_to_return[rc_idx]:set_meta("num_nulls", M[i].num_nulls)
        rc_idx = rc_idx + 1
      end
    end
    print("Successfully loaded ", row_idx, " rows")
    return cols_to_return

end
-- load( "test.csv" , dofile("meta.lua"), nil)
