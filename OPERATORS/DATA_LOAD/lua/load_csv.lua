require "validate_meta"
require 'globals'
require 'extract_fn_proto'
require 'error_code'


local Dictionary = require 'dictionary_dataload'
local plstring = require 'pl.stringx'
local Column = require 'Column'
local plpath = require 'pl.path'
local pllist = require 'pl.List'

local ffi = require "ffi"
ffi.cdef([[
void *memset(void * str, int c, size_t n);
]])
local rootdir = os.getenv("Q_SRC_ROOT")
local get_cell = assert(extract_fn_proto(rootdir.."/OPERATORS/DATA_LOAD/src/get_cell.c"))
local txt_to_SC = assert(extract_fn_proto(rootdir.."/OPERATORS/DATA_LOAD/src/txt_to_SC.c"))
local txt_to_I1 = assert(extract_fn_proto(rootdir.."/OPERATORS/DATA_LOAD/gen_src/_txt_to_I1.c"))
local txt_to_I2 = assert(extract_fn_proto(rootdir.."/OPERATORS/DATA_LOAD/gen_src/_txt_to_I2.c"))
local txt_to_I4 = assert(extract_fn_proto(rootdir.."/OPERATORS/DATA_LOAD/gen_src/_txt_to_I4.c"))
local txt_to_I8 = assert(extract_fn_proto(rootdir.."/OPERATORS/DATA_LOAD/gen_src/_txt_to_I8.c"))
local txt_to_F4 = assert(extract_fn_proto(rootdir.."/OPERATORS/DATA_LOAD/gen_src/_txt_to_F4.c"))
local txt_to_F8 = assert(extract_fn_proto(rootdir.."/OPERATORS/DATA_LOAD/gen_src/_txt_to_F8.c"))
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

local c = ffi.load("load_csv.so")
-- ----------------
-- load( "CSV file to load", "meta data", "Global Metadata")
-- Loads the CSV file and stores in the Q internal format
--
-- returns : table containing list of files for each column defined in metadata.
--           If any error was encountered during load operation then negative status code
-- ----------------

function load_csv( 
  csv_file_path, 
  M,  -- metadata
  load_global_settings
  )
  local column_list = {}
  local dict_table = {}
  local col_num_nil = {}
  local size_of_data_list = {}
   
  assert(type(_G["Q_DICTIONARIES"]) == "table",g_err.NULL_DICTIONARY_ERROR)
   
  assert( csv_file_path ~= nil and plpath.isfile(csv_file_path),g_err.INPUT_FILE_NOT_FOUND)
  assert( plpath.getsize(csv_file_path) ~= 0,g_err.INPUT_FILE_EMPTY)
  assert( _G["Q_DATA_DIR"] ~= nil and plpath.isdir(_G["Q_DATA_DIR"]), g_err.Q_DATA_DIR_NOT_FOUND)
  assert( _G["Q_META_DATA_DIR"] ~= nil and plpath.isdir(_G["Q_META_DATA_DIR"]), g_err.Q_META_DATA_DIR_NOT_FOUND)
  validate_meta(M)
   

  for i = 1, #M do 
    --default to true
    if M[i].is_load == nil then 
      M[i].is_load = true
    end
      
    if M[i].is_load == true then
      if M[i].qtype == "SC" then
        size_of_data_list[i] = M[i].width
      else
        size_of_data_list[i] = g_qtypes[M[i].qtype]["width"]
      end
      
      -- If user does no specify null value, then treat null = true as default
      if M[i].has_nulls == nil or M[i].has_nulls == "" then
        M[i].has_nulls = true
      end
    
      column_list[i] = Column{field_type=M[i].qtype, 
                 field_size=size_of_data_list[i], 
                 filename= _G["Q_DATA_DIR"] .. "_" .. M[i].name,
                 write_vector=true,
                 nn=M[i].has_nulls }
      col_num_nil[i] = nil
                 
      if M[i].qtype == "SV" then
        -- initialization to {} is required, if not done then in the second statement dict_table[i].dict, dict_table[i] will be nil
        dict_table[i] = {}
        dict_table[i].dict = assert(Dictionary(M[i]), g_err.ERROR_CREATING_ACCESSING_DICT )
        dict_table[i].add_new_value = M.add
        column_list[i]:set_meta("dir",dict_table[i].dict)
      end 
    end    
  end
   
   -- mmap function here
   f_map = ffi.gc( c.f_mmap(csv_file_path, false), c.f_munmap)
   assert(f_map.status == 0 , "Mmap failed")
   local X = ffi.cast("char *", f_map.ptr_mmapped_file)
   local nX = tonumber(f_map.ptr_file_size)
   assert(nX > 0, "File cannot be empty")
   
   local x_idx = 0
   
   -- Take the max value from all the types
   -- pllist is a penlight list class, here used to find maximum values among the list of values 
   -- https://stevedonovan.github.io/Penlight/api/classes/pl.List.html
   local l = pllist()
   for i, value in pairs(g_width) do
    l:append(value) 
   end
   l:append(2*g_max_width_SC)
   local min, cbuf_sz = l:minmax()  -- max value will be cbuff_sz, since c conversion will be to either one of the types contained in g_sz
   
   l:append(2*g_max_width_SV)
   local min, buf_sz = l:minmax() -- buf_sz is the max size of the input indicated by globals
   
   local buf = ffi.gc(c.malloc(buf_sz), c.free)
   local cbuf = ffi.gc(c.malloc(cbuf_sz), c.free)
   local is_null = ffi.gc(c.malloc(1), c.free)
   local ncols = #M
   local row_idx = 0
   local col_idx = 0
   
   while true do
      local is_last_col
      if col_idx == (ncols-1) then
         is_last_col = true;
      else
         is_last_col = false;
      end
      x_idx = tonumber( c.get_cell(X, nX, x_idx, is_last_col, buf, buf_sz)  )

      assert(x_idx > 0 , g_err.INVALID_INDEX_ERROR)
      -- print(row_idx, col_idx, ffi.string(buf))
      
      -- check if the column needs to be skipped while loading or not 
      if column_list[col_idx  + 1 ] then 
        ffi.fill(is_null, 1, 255) -- initially will be false = 1
  
        if M[col_idx + 1].qtype == "SV" then 
          if plstring.strip(ffi.string(buf)) ~= "" then 
            local ret_number = dict_table[col_idx + 1].dict:add_with_condition(ffi.string(buf), dict_table[col_idx + 1].add_new_value)  
            ffi.copy(buf, tostring(ret_number))
          end   
        elseif M[col_idx + 1].qtype == "SC" then 
          assert( string.len(ffi.string(buf)) <= M[col_idx + 1].width -1, g_err.STRING_GREATER_THAN_SIZE )  
        end
             
        ffi.C.memset(cbuf, 0, size_of_data_list[col_idx + 1])
        --print(ffi.string(buf))
        local str = plstring.strip(ffi.string(buf))
        --if ffi.string(buf) == "" then 
        if str == "" then 
          -- nil values
          assert( M[col_idx + 1].has_nulls == true, g_err.NULL_IN_NOT_NULL_FIELD ) 
          ffi.fill(is_null, 1,0)
          if col_num_nil[col_idx + 1] == nil then 
            col_num_nil[col_idx + 1] =  1 
          else 
            col_num_nil[col_idx + 1] = col_num_nil[col_idx + 1] + 1
          end          
        else 
          local status = nil
          local q_type = M[col_idx + 1].qtype
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
            error("Data type : " .. q_type .. " Not supported ")
          end
          
          assert( status >= 0 , g_err.INVALID_DATA_ERROR )
        end   
           
        column_list[col_idx+1]:put_chunk(1, cbuf, is_null)

        if is_last_col then
           row_idx = row_idx + 1
           col_idx = 0;
        else
           col_idx = col_idx + 1 
        end
        
        if x_idx >= nX then 
          break 
        end
      end
   end

   for i, column in pairs(column_list) do
      column:eov()
      -- print(column:length())
   end
   print("Completed successfully")
   return column_list
end
