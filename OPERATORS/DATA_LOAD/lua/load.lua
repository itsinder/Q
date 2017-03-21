package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"

  _G["Q_DATA_DIR"] = "./"
  _G["Q_META_DATA_DIR"] = "./"
  _G["Q_DICTIONARIES"] = {}
 
require "validate_meta"
require 'globals'
--require 'parser'
local Dictionary = require 'dictionary'
local Vector = require 'Vector'
local Column = require 'Column'
require 'pl'
require 'utils'

local ffi = require "ffi"
ffi.cdef([[
  typedef struct {
    char *fpos;
    void *base;
    unsigned short handle;
    short flags;
    short unget;
    unsigned long alloc;
    unsigned short buffincrement;
  } FILE;
  void * malloc(size_t size);
  void free(void *ptr);

  typedef struct {void* ptr_mmapped_file; size_t ptr_file_size; int status; } mmap_struct;
  mmap_struct* f_mmap(const char* file_name, bool is_write);
  int f_munmap(mmap_struct* map);
  FILE *fopen(const char *path, const char *mode);

  extern size_t get_cell(char *X, size_t nX, size_t xidx, bool is_last_col, char *buf, size_t bufsz);
  
  int txt_to_I1(const char *X, int base, int8_t *ptr_out);
  int txt_to_I2(const char *X, int base, int16_t *ptr_out);
  int txt_to_I4(const char *X, int base, int32_t *ptr_out);
  int txt_to_I8(const char *X, int base, int64_t *ptr_out);
  int txt_to_F4(const char *X, float *ptr_out);
  int txt_to_F8(const char *X, double *ptr_out);
  int txt_to_SC(const char *X, char *out, size_t sz_out);
  
  int I1_to_txt(int8_t *in, const char * const fmt, char *X, size_t nX);
  int I2_to_txt(int16_t *in, const char * const fmt, char *X, size_t nX);
  int I4_to_txt(int32_t *in, const char * const fmt, char *X, size_t nX);
  int I8_to_txt(int64_t *in, const char * const fmt, char *X, size_t nX);
  int F4_to_txt(float *in, const char * const fmt, char *X, size_t nX);  
  int F8_to_txt(double *in, const char * const fmt, char *X, size_t nX);
  int SC_to_txt(char * const in, uint32_t width, char * X, size_t nX);  

]])
-- ----------------
-- load( "CSV file to load", "meta data", "Global Metadata")
-- Loads the CSV file and stores in the Q internal format
--
-- returns : table containing list of files for each column defined in metadata.
--           If any error was encountered during load operation then negative status code
-- ----------------

-- validate meta-data & create vector + null vector for each of the file being created
local c = ffi.load("load_csv.so")


function load( csv_file_path, metadata, load_global_settings)
  local column_list = {}
  local dict_table = {}
  local col_num_nil = {}
  local data_ptr = {}
  local size_of_data_list = {}
   
  assert( valid_file(csv_file_path),"Please make sure that csv_file_path is correct")
  assert( path.getsize(csv_file_path) ~= 0, "File should not be empty")
  assert( valid_dir(_G["Q_DATA_DIR"]), "Please make sure that Q_DATA_DIR points to correct directory")
  assert( valid_dir(_G["Q_META_DATA_DIR"]), "Please make sure that Q_META_DATA_DIR points to correct directory")
  validate_meta(metadata)
   

  for i = 1, #metadata do 
    -- If metadata name is not empty/null, then only create column
    if stringx.strip(metadata[i].name) ~= "" then
      if metadata[i].type == "SC" then
        size_of_data_list[i] = metadata[i].size
      else
        size_of_data_list[i] = g_qtypes[metadata[i].type]["width"]
      end
      
      -- If user does no specify null value, then treat null = true as default
      if metadata[i].null == nil or metadata[i].null == "" then
        metadata[i].null = true
      end
    
      column_list[i] = Column{field_type=metadata[i].type, 
                 field_size=size_of_data_list[i], 
                 filename= _G["Q_DATA_DIR"] .. "_" .. metadata[i].name,
                 write_vector=true,
                 nn=metadata[i].null }
      col_num_nil[i] = nil
                 
      if metadata[i].type == "SV" then
        dict_table[i] = {}
        dict_table[i].dict = assert(Dictionary(metadata[i]), "Error while creating/accessing dictionary for metadata " )
        dict_table[i].dict_name = metadata.dict
        dict_table[i].add_new_value = metadata.add or true   
      end 
 
      data_ptr[i] = {}
      data_ptr[i].size_of_data = size_of_data
    end    
  end
   
   -- TODO Put nils for columns that you do not want to load 
   --[[local column_list = {
      Column{field_type="I4", write_vector=true, filename="_i4"},
      Column{field_type="I2", write_vector=true, filename="_i2"},
   } --]]
 
   -- mmap function here
   f_map = ffi.gc( c.f_mmap(csv_file_path, false), c.f_munmap)
   assert(f_map.status == 0 , "Mmap failed")
   local X = ffi.cast("char *", f_map.ptr_mmapped_file)
   local nX = tonumber(f_map.ptr_file_size)
   assert(nX > 0, "File cannot be empty")
   
   local x_idx = 0
   local buf_sz = 1024
   --TODO bufsize should be calculated from c data
   --TODO note double for SC type, SV max length in meta data
   local buf = ffi.gc(c.malloc(buf_sz), c.free)
   local cbuf = ffi.gc(c.malloc(1024), c.free)
   local is_null = ffi.gc(c.malloc(1), c.free)
   local ncols = #metadata
   local row_idx = 0
   local col_idx = 0
   
   while true do
      local is_last_col
      if ( col_idx == (ncols-1) ) then
         is_last_col = true;
      else
         is_last_col = false;
      end
      x_idx = tonumber( c.get_cell(X, nX, x_idx, is_last_col, buf, buf_sz)  )

      assert(x_idx > 0 , "Index has to be valid")
      print(row_idx, col_idx, ffi.string(buf))
      
      
      -- TODO if column_list[colidx] == nil then continue end 

      ffi.fill(is_null, 1, 255) -- initially will be false = 1

      if metadata[col_idx + 1].type == "SV" then 
        -- dictionary throws error if any during the add operation
        if stringx.strip(ffi.string(buf)) ~= "" then 
          local ret_number = dict_table[col_idx + 1].dict:add_with_condition(ffi.string(buf), dict_table[col_idx + 1].add_new_value)  
          ffi.copy(buf, tostring(ret_number))
        end   
      elseif metadata[col_idx + 1].type == "SC" then 
        assert( string.len(ffi.string(buf)) <= metadata[col_idx + 1].size -1, " contains string greater than allowed size. Please correct data or metadata.")  
      end
           
      if ffi.string(buf) == "" then 
        -- nil values
        assert( metadata[col_idx + 1].null == true, " Null value found in not null field " ) 
        ffi.fill(is_null, 1,0)
        if col_num_nil[col_idx + 1] == nil then 
          col_num_nil[col_idx + 1] =  1 
        else 
          col_num_nil[col_idx + 1] = col_num_nil[col_idx + 1] + 1
        end          
      end
      
      
      -- for null fields set all bytes to \0
      if ffi.string(buf) == "" then 
        ffi.C.memset(cbuf, 0, size_of_data_list[col_idx + 1])
      else 
        local status = nil
        local q_type = metadata[col_idx + 1].type
        local function_name = g_qtypes[q_type]["txt_to_ctype"]
        -- for fixed size string pass the size of string data also
        if q_type == "SC" then
          local ssize = ffi.cast("size_t", size_of_data_list[col_idx + 1])
          status = c[function_name](buf, cbuf, ssize)
        elseif q_type == "I1" or q_type == "I2" or q_type == "I4" or q_type == "I8" or q_type == "SV" then
          -- For now second parameter , base is 10 only
          status = c[function_name](buf, 10, cbuf)
        elseif q_type == "F4" or q_type == "F8"  then 
          status = c[function_name](buf, cbuf)
        else 
          error("Data type" .. q_type .. " Not supported ")
        end
          assert( status >= 0 , "Invalid data found")
      end   
           
      column_list[col_idx+1]:put_chunk(1, cbuf, is_null)

      if ( is_last_col ) then
         row_idx = row_idx + 1
         col_idx = 0;
      else
         col_idx = col_idx + 1 
      end

      if ( x_idx >= nX ) then  break end
   end
   -- TODO : remove column_list length, as it might contain null values
   for i =1, #column_list do
      column_list[i]:eov()
      print(column_list[i]:length())
   end
   print("Completed successfully")
   -- TODO create list and return that , not this
   return column_list

end

-- load( "test.csv" , dofile("meta.lua"), nil)
