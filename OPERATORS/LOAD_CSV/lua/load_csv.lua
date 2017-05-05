-- RS Delete this line - taken care of by LUA_INIT set up
local extract_fn_proto = require 'extract_fn_proto'
local validate_meta = require "validate_meta"
local error_code = require 'error_code'

local Dictionary = require 'dictionary'
local Column = require 'Column'
local dbg = require 'debugger'
local plstring = require 'pl.stringx'
local plfile = require 'pl.file'
--RS Use extract_fn_proto for txt_to_* and so on
--RS Also, you don;t need *_to_txt here. You need it in print. Delete
--RS Don't have stuff you do not need. DO you need FILE> Do you need fopen?
--RS and so on....
local fn_malloc = require 'ffi_malloc'
local ffi = require "ffi"
ffi.cdef([[
  void *memset(void *s, int c, size_t n);
  size_t strlen(const char *str);
]])

local rootdir = os.getenv("Q_SRC_ROOT")
local get_cell = assert(extract_fn_proto(rootdir.."/OPERATORS/LOAD_CSV/src/get_cell.c"))
local txt_to_SC = assert(extract_fn_proto(rootdir.."/OPERATORS/LOAD_CSV/src/txt_to_SC.c"))
local txt_to_I1 = assert(extract_fn_proto(rootdir.."/OPERATORS/LOAD_CSV/gen_src/_txt_to_I1.c"))
local txt_to_I2 = assert(extract_fn_proto(rootdir.."/OPERATORS/LOAD_CSV/gen_src/_txt_to_I2.c"))
local txt_to_I4 = assert(extract_fn_proto(rootdir.."/OPERATORS/LOAD_CSV/gen_src/_txt_to_I4.c"))
local txt_to_I8 = assert(extract_fn_proto(rootdir.."/OPERATORS/LOAD_CSV/gen_src/_txt_to_I8.c"))
local txt_to_F4 = assert(extract_fn_proto(rootdir.."/OPERATORS/LOAD_CSV/gen_src/_txt_to_F4.c"))
local txt_to_F8 = assert(extract_fn_proto(rootdir.."/OPERATORS/LOAD_CSV/gen_src/_txt_to_F8.c"))
local f_mmap = assert(extract_fn_proto(rootdir.."/UTILS/src/f_mmap.c"))
local f_munmap = assert(extract_fn_proto(rootdir.."/UTILS/src/f_munmap.c"))

ffi.cdef(get_cell)
ffi.cdef(txt_to_SC)
ffi.cdef(txt_to_I1)
ffi.cdef(txt_to_I2)
ffi.cdef(txt_to_I4)
ffi.cdef(txt_to_I8)
ffi.cdef(txt_to_F4)
ffi.cdef(txt_to_F8)
ffi.cdef(f_mmap)
ffi.cdef(f_munmap)

-- ----------------
-- RS TODO Use compile_so to create load_csv.so
local cee = ffi.load("load_csv.so")

function mk_out_buf(
  in_buf, 
  m,  -- m is meta data for field 
  d,  -- d is dictiomnary for field 
  out_buf,
  out_buf_len,
  err_loc
)
    -- commented the below line to fix the performance testing
    --ffi.cdef("size_t strlen(const char *);")
    local in_buf_len = assert( tonumber(cee.strlen(in_buf)))

    if m.qtype == "SV" then 
      assert(in_buf_len <= m.max_width, err_loc .. g_err.STRING_TOO_LONG)
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
      err_loc .. "dictionary does not have string " .. ffi.string(in_buf))
      ffi.cast("int *", out_buf)[0] = stridx
    end   
    --=======================================
    if m.qtype == "SC" then 
      assert(in_buf_len <= m.width, err_loc .. g_err.STRING_TOO_LONG)
      ffi.copy(out_buf, in_buf, in_buf_len)
    end
    --=======================================
    local converter = assert(g_qtypes[m.qtype]["txt_to_ctype"])
    local ctype     = assert(g_qtypes[m.qtype]["ctype"])
    local status = 0
    local casted = ffi.cast(ctype .. " *", out_buf)
    --=====================================
    if m.qtype == "I1" then status = cee[converter](in_buf, 10, casted) end
    if m.qtype == "I2" then status = cee[converter](in_buf, 10, casted) end
    if m.qtype == "I4" then status = cee[converter](in_buf, 10, casted) end
    if m.qtype == "I8" then status = cee[converter](in_buf, 10, casted) end
    if m.qtype == "F4" then status = cee[converter](in_buf, casted) end
    if m.qtype == "F8" then status = cee[converter](in_buf, casted) end
    --=====================================
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
  --assert(status == 0, g_err.TYPE_CONVERTER_FAILED .. m.qtype)
  assert(status == 0, g_err.INVALID_DATA_ERROR .. m.qtype)
end

return function ( 
  infile,   -- input file to read (string)
  M,  -- metadata (table)
  global_settings -- TODO unused for now
)
    local plpath = require 'pl.path'
    assert(type(_G["Q_DICTIONARIES"]) == "table",g_err.NULL_DICTIONARY_ERROR)
    local cols = {} -- cols[i] is Column used for column i 
    local dicts = {} -- dicts[i] is di ctionary used for column i

    assert( infile ~= nil and plpath.isfile(infile),g_err.INPUT_FILE_NOT_FOUND)
    assert(plpath.getsize(infile) > 0, g_err.INPUT_FILE_EMPTY)
    assert( _G["Q_DATA_DIR"] ~= nil and plpath.isdir(_G["Q_DATA_DIR"]), g_err.Q_DATA_DIR_NOT_FOUND)
    assert( _G["Q_META_DATA_DIR"] ~= nil and plpath.isdir(_G["Q_META_DATA_DIR"]), g_err.Q_META_DATA_DIR_NOT_FOUND)
    validate_meta(M)

    -- In this loop (1) calculate max_txt_width (2) create Column for each
    -- is_load column (3) create Dictionary for each is_load SV column
    local max_txt_width = 0
    for i = 1, #M do 
      if M[i].is_load then 
        local fld_width = nil
        -- Update max_width
        local fld_max_txt_width = 0
        if M[i].qtype == "SV" then
          -- times 2 to deal with escaping
          fld_max_txt_width = 2 * assert(M[i].max_width)
        elseif M[i].qtype == "SC" then
          fld_width = M[i].width -- set only for SC
          -- times 2 to deal with escaping
          fld_max_txt_width = 2 * assert(M[i].width)
        else
          fld_max_txt_width = assert(g_qtypes[M[i].qtype].max_txt_width)
        end
        max_txt_width = ( fld_max_txt_width > max_txt_width ) 
        and fld_max_txt_width or max_txt_width 
        --==============================
        cols[i] = Column{
          field_type=M[i].qtype, 
          field_size=fld_width, 
          filename= _G["Q_DATA_DIR"] .. "/_" .. M[i].name,
          write_vector=true,
          nn=M[i].has_nulls }
          --==============================
          M[i].num_nulls = 0
          --==============================
          if M[i].qtype == "SV" then
            local x = Dictionary(M[i].dict)
            dicts[i] = assert(Dictionary(M[i].dict), 
            "error creating dictionary " .. M[i].dict .. " for " .. M[i].name)
            cols[i]:set_meta("dir",dicts[i])
          end 
        end    
      end
      assert(max_txt_width > 0)
      --===========================
      f_map = ffi.gc( cee.f_mmap(infile, false), cee.f_munmap)
      assert(f_map.status == 0 , g_err.MMAP_FAILED)
      local X = ffi.cast("char *", f_map.ptr_mmapped_file)
      local nX = tonumber(f_map.ptr_file_size)
      assert(nX > 0, g_err.FILE_EMPTY)

      local x_idx = 0
      local out_buf_sz = 1024 -- TODO FIX 
      -- to do remove hardcoding of 1024
      local in_buf  = fn_malloc(max_txt_width)
      local out_buf = fn_malloc(out_buf_sz)
      local is_nn   = fn_malloc(1)
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
        ffi.C.memset(in_buf, 0, max_txt_width) -- always init to 0
        ffi.C.memset(is_nn, 0, 1) -- assume null
        -- create an error message that might be needed
        local err_loc = "error in row " .. row_idx .. " column " .. col_idx
        --local err_loc = g_err.GET_CELL_ERROR(row_idx, col_idx)
        --local err_loc = g_err.INVALID_INDEX_ERROR
        x_idx = tonumber(
        cee.get_cell(X, nX, x_idx, is_last_col, in_buf, max_txt_width))
        assert(x_idx > 0 , err_loc .. g_err.INVALID_INDEX_ERROR)
        if ( M[col_idx].is_load ) then 
          -- print(row_idx, col_idx, ffi.string(buf))
          -- local in_buf_len = assert(string.len(ffi.string(in_buf)))
          local str = plstring.strip(ffi.string(in_buf))
          --local is_null = ( in_buf[0] == '\0' )
          local is_null = (str == "")
          --print("in buf = "..str)
          -- Process null value case
          if is_null then 
            assert(M[col_idx].has_nulls, 
            err_loc .. g_err.NULL_IN_NOT_NULL_FIELD) 
            M[col_idx].num_nulls = M[col_idx].num_nulls + 1
          else 
            ffi.C.memset(is_nn, 1, 1) -- value IS Not Null 
            mk_out_buf(in_buf, M[col_idx], dicts[col_idx], out_buf, out_buf_sz, err_loc)
          end
          cols[col_idx]:put_chunk(1, out_buf, is_nn)
        end
          --=======================================
        if ( is_last_col ) then
          row_idx = row_idx + 1
          col_idx = 1;
        else
          col_idx = col_idx + 1 
        end
        assert(x_idx <= nX) 
        if  (x_idx >= nX) then break end
      end
      assert(x_idx == nX, g_err.DID_NOT_END_PROPERLY)
      assert(col_idx == 1, g_err.BAD_NUMBER_COLUMNS)
      --======================================
      local cols_to_return = {} 
      local rc_idx = 1
      for i = 1, #M do
        if ( M[i].is_load ) then 
          cols[i]:eov()
          if ( ( M[i].has_nulls ) and ( M[i].num_nulls == 0 ) ) then
            -- TODO drop the null column. Indrajeet to provide
            local null_file = _G["Q_DATA_DIR"] .. "/_" .. M[i].name .. "_nn"
            assert(plfile.delete(null_file),g_err.INPUT_FILE_NOT_FOUND)
          end
          cols_to_return[rc_idx] = cols[i]
          cols_to_return[rc_idx]:set_meta("num_nulls", M[i].num_nulls)
          rc_idx = rc_idx + 1
        end
      end
      -- print("Successfully loaded ", row_idx, " rows")
      return cols_to_return

end
--_G["Q_DATA_DIR"] = "./"
--_G["Q_META_DATA_DIR"] = "./"
--_G["Q_DICTIONARIES"] = {}
--load_csv( "../test/gm3d1.csv" , dofile("../test/gm3.lua"), nil)
