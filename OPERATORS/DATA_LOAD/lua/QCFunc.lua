local ffi = require("ffi") 
local so_file_path_name = "../src/QCFunc.so" --path for .so file
local qCLib  = ffi.load(so_file_path_name) 

local binfilepath = "./out/"

ffi.cdef[[
  void *malloc(size_t size);
  void free(void *ptr);


  typedef struct FILE FILE;  
  FILE* createFile(const char *fname);
  void write(FILE *fp, const void* val, int size);
  void writeNull(FILE *fp, uint8_t val, int size);
  void close(FILE *fp);
  int txt_to_d(const char *X, double *ptr_out);
  int txt_to_I1(const char *X, int8_t *ptr_out);
  int txt_to_I2(const char *X, int16_t *ptr_out);
  int txt_to_I4(const char *X, int32_t *ptr_out);
  int txt_to_I8(const char *X, int64_t *ptr_out);
  
  uint8_t setBit(int colno, uint8_t byteval, int row_cnt);
  
  ]]


function setBit(col, byteval, row_cnt)

  byteval = qCLib["setBit"](col, byteval ,row_cnt)
  return byteval
end


-- --------------------------------------------------------
-- Converts given text value into C value representation
-- --------------------------------------------------------
function convertTextToCValue(funName, data, sizeOfCData) 
  
  if(sizeOfCData == nil) then 
      print("FunName " ..funName .. " Data " .. data)
  end
  
  local cValue = ffi.C.malloc(sizeOfCData)
  local status = qCLib[funName](data, cValue)
  
  ffi.gc( cValue, ffi.C.free )
  
  -- TODO : Handle scenarios where status is negative. i.e. Error conditions
  return cValue
end

--- ######################## FILE Related function Starts ##########

function create(fileName) 
  filepath = binfilepath..fileName
  -- print("filepath : " .. filepath .. " Length is " .. #filepath)
  -- local filePathArg = ffi.new("char [?]", #filepath, filepath)
  -- local fp = qCLib["createFile"](filePathArg);
  local fp = qCLib["createFile"](filepath);
  return fp;
end

function close(fp) 
    qCLib["close"](fp)
end

function write(fp,data, size) 
  -- ffi.cast("void *", data), this should be used on data, before writing it to ensure that its pointer 
  qCLib["write"](fp, data, size)
  
end

function writeNull(fp,data, size) 
  -- ffi.cast("void *", data), this should be used on data, before writing it to ensure that its pointer 
  qCLib["writeNull"](fp, data, size)
  
end

--- ####################### FIEL Related function ends ################
