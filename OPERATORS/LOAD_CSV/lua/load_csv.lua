-- RS Delete this line - taken care of by LUA_INIT set up
package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
 
require "validate_meta"
local Dictionary = require 'dictionary'
local Column = require 'Column'
-- local dbg = require 'debugger'
--RS Use extract_fn_proto for txt_to_* and so on
--RS Also, you don;t need *_to_txt here. You need it in print. Delete
--RS Don't have stuff you do not need. DO you need FILE> Do you need fopen?
--RS and so on....
local ffi = require "ffi"
ffi.cdef([[
void *memset(void *s, int c, size_t n);
typedef struct _mmap_struct {
    void* ptr_mmapped_file;
    size_t file_size;
    int status;
} mmap_struct;
extern mmap_struct*
f_mmap(
   const char * const file_name,
   bool is_write
);
extern int 
f_munmap(
    mmap_struct* map        
);
  size_t strlen(const char *str);
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
-- RS Use compile_so to create load_csv.so
local cee = ffi.load("load_csv.so")

function mk_out_buf(
  in_buf, 
  m,  -- m is meta data for field 
  d,  -- d is dictiomnary for field 
  out_buf,
  out_buf_len,
  err_loc
  )
    ffi.cdef("size_t strlen(const char *);")
    local in_buf_len = assert( tonumber(cee.strlen(in_buf)))

    if m.qtype == "SV" then 
      assert(in_buf_len <= m.max_width, err_loc .. "string too long ")
      local stridx = nil
      if ( m.add ) then
        stridx = d.add(in_buf)
      else
        stridx = d.get_index_by_string(in_buf)
      end
      assert(stridx,
      err_loc .. "dictionary does not have string " .. in_buf)
      ffi.cast("int *", out_buf)[0] = stridx
    end   
    --=======================================
    if m.qtype == "SC" then 
      assert(in_buf_len <= m.width, err_loc .. "string too long ")
      ffi.copy(out_buf, in_buf)
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
  assert(status == 0, "text converter failed for qtype " .. m.qtype)
end

function load_csv( 
  infile,   -- input file to read (string)
  M,  -- metadata (table)
  global_settings -- TODO unused for now
  )
    local plpath = require 'pl.path'
    assert(plpath.isdir(_G["Q_DATA_DIR"]))
    assert(plpath.isdir(_G["Q_META_DATA_DIR"]))
    assert(type(_G["Q_DICTIONARIES"]) == "table")
    local cols = {} -- cols[i] is Column used for column i 
    local dicts = {} -- dicts[i] is di ctionary used for column i

    assert(plpath.isfile(infile), "input file not found")
    assert(plpath.getsize(infile) > 0, "input file empty")
    assert(plpath.isdir(_G["Q_DATA_DIR"]), "directory not found -- Q_DATA_DIR")
    assert(plpath.isdir(_G["Q_META_DATA_DIR"]), "directory not found -- Q_META_DATA_DIR")
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
            dicts[i] = assert(Dictionary(M[i].name), 
            "error with dictionary for " .. M[i].name)
          end 
        end    
      end
      assert(max_txt_width > 0)
      --===========================
      f_map = ffi.gc( cee.f_mmap(infile, false), cee.f_munmap)
      assert(f_map.status == 0 , "Mmap failed")
      local X = ffi.cast("char *", f_map.ptr_mmapped_file)
      local nX = tonumber(f_map.ptr_file_size)
      assert(nX > 0, "File cannot be empty")

      local x_idx = 0
      local out_buf_sz = 1024 -- TODO FIX 
      local in_buf  = ffi.cast("char  *", ffi.gc(cee.malloc(max_txt_width), ffi.C.free))
      local out_buf = ffi.cast("char *", ffi.gc(cee.malloc(out_buf_sz), ffi.C.free))
      local is_nn   = ffi.cast("char *", ffi.gc(cee.malloc(1), ffi.C.free))
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
        x_idx = tonumber(
        cee.get_cell(X, nX, x_idx, is_last_col, in_buf, max_txt_width))
        assert(x_idx > 0 , err_loc)
        if ( M[col_idx].is_load ) then 
          -- print(row_idx, col_idx, ffi.string(buf))
          -- local in_buf_len = assert(string.len(ffi.string(in_buf)))
          local is_null = ( in_buf[0] == '\0' )
          -- Process null value case
          if is_null then 
            assert(M[col_idx].has_nulls, 
            err_loc ..  "Null value found in not null field " ) 
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
      assert(x_idx == nX, "Didn't end up properly")
      assert(col_idx == 1, "bad number of columns on last line")
      --======================================
      local cols_to_return = {} 
      local rc_idx = 1
      for i = 1, #M do
        if ( M[i].is_load ) then 
          cols[i]:eov()
          if ( ( M[i].has_nulls ) and ( M[i].num_nulls == 0 ) ) then
            -- TODO drop the null column. Indrajeet to provide
          end
          cols_to_return[rc_idx] = cols[i]
          cols_to_return[rc_idx]:set_meta("num_nulls", M[i].num_nulls)
          rc_idx = rc_idx + 1
        end
      end
      print("Successfully loaded ", row_idx, " rows")
      return cols_to_return

end
-- _G["Q_DATA_DIR"] = "./"
-- _G["Q_META_DATA_DIR"] = "./"
-- _G["Q_DICTIONARIES"] = {}
-- load_csv( "gm1d1.csv" , dofile("gm1.lua"), nil)
