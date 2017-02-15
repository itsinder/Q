local ffi = require("ffi") 
local so_file_path_name = "../obj/q_c_functions.so" --path for .so file
local q_c_lib  = ffi.load(so_file_path_name) 

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
  ]]


function reset_chunk_data(chunk, size_of_c_data ,chunk_size)
  ffi.C.memset(chunk, 0, size_of_c_data * chunk_size)
end

function allocate_chunk_data(ctype, size_of_c_data ,chunk_size)
  local chunk = ffi.C.malloc(size_of_c_data*chunk_size)
  -- explicit cast is required for luaffi to work, luajit ffi implicitly casts void * to any data type
  local chunk = ffi.cast(ctype.. " * ", chunk)
     
  ffi.gc( chunk, ffi.C.free )  
  return chunk
  
end


function convert_data(function_name, q_type, data, c_value, size_of_c_data)
  -- for null fields set all bytes to \0
  if(data == nil) then 
    ffi.C.memset(c_value, 0, size_of_c_data)
  else 
    local status = nil
    -- for fixed size string pass the size of stirng data also
    if q_type == "SC" then
      local ssize = ffi.cast("size_t" ,size_of_c_data)
      status = q_c_lib[function_name](data, c_value, ssize)
    elseif ( q_type == "I1" or q_type == "I2" or q_type == "I4" or q_type == "I8" or q_type == "varchar") then
      -- For now second parameter , base is 10 only
      status = q_c_lib[function_name](data, 10, c_value)
    elseif q_type == "F4" or q_type == "F8"  then 
      status = q_c_lib[function_name](data, c_value)
    else 
      error("Data type" .. q_type .. " Not supported ")
    end
    
    -- negative status indicates erorr condition
    if(status < 0) then 
      error("Invalid data found")
    end
  end  
end
