local ffi = require("ffi") 
local so_file_path_name = "../obj/q_c_functions.so" --path for .so file
local q_c_lib  = ffi.load(so_file_path_name) 

ffi.cdef[[
  void *malloc(size_t size);
  void free(void *ptr);

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
  ]]



-- --------------------------------------------------------
-- Converts given text value into C value representation
-- --------------------------------------------------------
--[[ 

-- This function is devided into two function below, keeping here, since I havent checked for all reference of this function. 
-- I will remove this comment once all reference are updated 

function convert_text_to_c_value(function_name, ctype, data, size_of_c_data) 
    
  local c_value = ffi.C.malloc(size_of_c_data)
  -- explicit cast is required for luaffi to work, luajit ffi implicitly casts void * to any data type
  local c_value = ffi.cast(ctype.. " * ", c_value)
  local status = nil
  
  -- for fixed size string pass the size of stirng data also
  if ctype == "char" then
    local ssize = ffi.cast("size_t" ,size_of_c_data)
    -- status = qCLib[funName](data, cValue, sizeOfCData)
    status = q_c_lib[function_name](data, c_value, ssize)
  else
    status = q_c_lib[function_name](data, c_value)
  end
  
  -- negative status indicates erorr condition
  if(status < 0) then 
    error("Invalid data found")
  end
  
  ffi.gc( c_value, ffi.C.free )  
  return c_value
end
--]]

function allocate_chunk_data(ctype, size_of_c_data ,chunk_size)

  local chunk = ffi.C.malloc(size_of_c_data*chunk_size)
  -- explicit cast is required for luaffi to work, luajit ffi implicitly casts void * to any data type
  local chunk = ffi.cast(ctype.. " * ", chunk)
     
  ffi.gc( chunk, ffi.C.free )  
  return chunk
  
end

function covert_data(function_name, ctype, data, c_value, size_of_c_data)
  local status = nil
  -- for fixed size string pass the size of stirng data also
  if ctype == "char" then
    local ssize = ffi.cast("size_t" ,size_of_c_data)
    -- status = qCLib[funName](data, cValue, sizeOfCData)
    status = q_c_lib[function_name](data, c_value, ssize)
  elseif ( ctype == "int8_t" or ctype == "int16_t" or ctype == "int32_t" or ctype == "int64_t") then
    -- For now second parameter , base is 10 only
    status = q_c_lib[function_name](data, 10, c_value)
  elseif ctype == "float" or ctype == "double"  then 
    status = q_c_lib[function_name](data, c_value)
  else 
    error("Data type" .. ctype .. " Not supported ")
  end
  
  -- negative status indicates erorr condition
  if(status < 0) then 
    error("Invalid data found")
  end
  
end
