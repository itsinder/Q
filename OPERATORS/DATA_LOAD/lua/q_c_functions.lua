package.cpath = package.cpath .. ";../obj/q_c_functions.so;"

local ffi = require("ffi") 
local q_c_lib  = ffi.load("../obj/q_c_functions.so") 
local q_c_print_lib = ffi.load("../../PRINT/obj/q_c_print_functions.so")

ffi.cdef[[
  void *malloc(size_t size);
  void free(void *ptr);
  void *memset(void *str, int c, size_t n);

  typedef struct ssize_t ssize_t;
  typedef struct FILE FILE;  
  int txt_to_d(const char *X, double *ptr_out);
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
  
  ]]


function reset_chunk_data(chunk, size_of_c_data, chunk_size)
  ffi.C.memset(chunk, 0, size_of_c_data * chunk_size)
end

function allocate_chunk_data(ctype, size_of_c_data, chunk_size)
  local chunk = ffi.C.malloc(size_of_c_data*chunk_size)
  -- explicit cast is required for luaffi to work, luajit ffi implicitly casts void * to any data type
  local chunk = ffi.cast(ctype.. " * ", chunk)
     
  ffi.gc( chunk, ffi.C.free )  
  return chunk
  
end


function convert_txt_to_c(q_type, data, c_value, size_of_c_data)
  
  -- for null fields set all bytes to \0
  if data == nil then 
    ffi.C.memset(c_value, 0, size_of_c_data)
  else 
    local status = nil
    local function_name = g_qtypes[q_type]["txt_to_ctype"]
    -- for fixed size string pass the size of string data also
    if q_type == "SC" then
      local ssize = ffi.cast("size_t", size_of_c_data)
      status = q_c_lib[function_name](data, c_value, ssize)
    elseif q_type == "I1" or q_type == "I2" or q_type == "I4" or q_type == "I8" or q_type == "SV" then
      -- For now second parameter , base is 10 only
      status = q_c_lib[function_name](data, 10, c_value)
    elseif q_type == "F4" or q_type == "F8"  then 
      status = q_c_lib[function_name](data, c_value)
    else 
      error("Data type" .. q_type .. " Not supported ")
    end
    
    -- negative status indicates error condition
    if status < 0 then 
      error("Invalid data found")
    end
  end  
end


-- ----------------------------------
-- Converts c data into string representation of q data
-- 
-- function_name : name of the conversion function to be used
-- q_type : Q data type. e.g. I1, I2, F4, ../
-- c_data : pointer to the c data 
-- idx : index the c_data 
-- size_of_data : size of c data to be used
-- 
-- return string representation of c data 
-- ------------------------

function convert_c_to_txt(q_type, c_data, idx,  size_of_data)

  -- Take the size from globals.lua
  size_of_data = assert(size_of_data or tonumber(g_qtypes[q_type]["max_length"]))
  idx = idx or 0

  local function_name = g_qtypes[q_type]["ctype_to_txt"]
  local c_data = ffi.cast(g_qtypes[q_type]["ctype"] .. " * ", c_data)
    
  local actual_data_ptr = allocate_chunk_data("char", size_of_data , 1);
 
  local status
  if q_type == "SC" then
    status = q_c_print_lib[function_name](c_data + idx, size_of_data, actual_data_ptr, size_of_data )
  else 
    status = q_c_print_lib[function_name](c_data + idx, nil, actual_data_ptr, size_of_data)
  end

  local str = ffi.string(actual_data_ptr)
  return str
end

