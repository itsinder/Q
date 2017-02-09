local ffi = require("ffi") 
local so_file_path_name = "../obj/QCFunc.so" --path for .so file
local q_c_lib  = ffi.load(so_file_path_name) 

ffi.cdef[[
  void *malloc(size_t size);
  void free(void *ptr);

  typedef struct ssize_t ssize_t;
  typedef struct FILE FILE;  
  int txt_to_d(const char *X, double *ptr_out);
  int txt_to_I1(const char *X, int8_t *ptr_out);
  int txt_to_I2(const char *X, int16_t *ptr_out);
  int txt_to_I4(const char *X, int32_t *ptr_out);
  int txt_to_I8(const char *X, int64_t *ptr_out);
  int txt_to_SC(const char *X, char *out, size_t sz_out);
  
  ]]



-- --------------------------------------------------------
-- Converts given text value into C value representation
-- --------------------------------------------------------
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
