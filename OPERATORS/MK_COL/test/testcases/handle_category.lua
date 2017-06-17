local ffi = require 'ffi'
local plstring = require 'pl.stringx'
local qconsts = require 'Q/UTILS/lua/q_consts'

local number_of_testcases_passed = 0
local number_of_testcases_failed = 0
ffi.cdef
[[ 
  void *malloc(size_t size);
  void free(void *ptr);
  void *memset(void *str, int c, size_t n);
]]

local fns = {}
local failed_testcases = {}

fns.increment_failed_mkcol = function (index, v, str)
  print("testcase name :"..v.name)
  print("qtype: "..v.qtype)
  
  print("reason for failure "..str)
  number_of_testcases_failed = number_of_testcases_failed + 1
  table.insert(failed_testcases,index)
end

fns.print_result = function () 
  local str
  
  str = "----------MK_COL TEST CASES RESULT----------------\n"
  str = str.."No of successfull testcases "..number_of_testcases_passed.."\n"
  str = str.."No of failure testcases     "..number_of_testcases_failed.."\n"
  str = str.."-----------------------------------\n"
  str = str.."Testcases failed are     \n"
  for k,v in ipairs(failed_testcases) do
    str = str..v.."\n"
  end
  str = str.."Run bash test_mkcol.sh <testcase_number> for details\n\n"
  str = str.."-----------------------------------\n"
  print(str)
  local file = assert(io.open("nightly_build_mkcol.txt", "w"), "Nighty build file open error")
  assert(io.output(file), "Nightly build file write error")
  assert(io.write(str), "Nightly build file write error")
  assert(io.close(file), "Nighty build file close error")
end


fns.category1 = function (index, v, status, ret)
  -- print(ret)
  -- print(v.name)
  if status ~= false then
    fns["increment_failed_mkcol"](index, v, "Mk_col function does not return status = false")
    return false
  end
  
  if v.output_regex == nil then
    fns["increment_failed_mkcol"](index, v, "MK_Col : Output regex not given in category1 testcases")
    return false
  end
  
  
  local a, b, err = plstring.splitv(ret,':')
  err = plstring.strip(err) 
  
  -- trimming whitespace
  local error_msg = plstring.strip(v.output_regex) -- check it can be used from utils.
  local count = plstring.count(err, error_msg)
  if count > 0 then
    number_of_testcases_passed = number_of_testcases_passed + 1
    return true
  else
    fns["increment_failed_mkcol"](index, v, "testcase category1 failed , actual and expected error message does not match")
    -- print("actual output:"..err)
    -- print("expected output:"..error_msg)
  
  end

end

fns.category2 = function (index, v, status, ret)
  -- print(ret)
  
  if status ~= true then
    fns["increment_failed_mkcol"](index, v, "Mk_col function does not return status = true")
    return false
  end
  
  if type(ret) ~= 'Column' then
    fns["increment_failed_mkcol"](index, v, "Mk_col function does not return Column")
    return false
  end
  
  
  for i=1,ret:length() do  
    local result = ret:get_element(i-1)
    local ctype =  qconsts.qtypes[ret:fldtype()]["ctype"]
    local str = ffi.cast(ctype.." *",result)
    local final_result = str[0]
    local is_float = ret:fldtype() == "F4" or ret:fldtype() == "F8"
    -- to handle the extra decimal values put in case of Float
    if is_float then
      local precision = v.precision
      precision = math.pow(10,precision)
      final_result = precision * final_result
      final_result = math.floor(final_result)
      final_result = final_result / precision
    end
    
    -- print(final_result , v.input[i])
    if final_result ~= v.input[i] then
      fns["increment_failed_mkcol"](index, v, "Mk_col input output mismatch input = "..v.input[i]..
        " output = "..final_result)
      return false
    end
    
  end
  
  number_of_testcases_passed = number_of_testcases_passed + 1
  -- print("Testing successful ", v.name)
  return true
end

return fns
