local ffi = require 'ffi'
local plstring = require 'pl.stringx'
local number_of_testcases_passed = 0
local number_of_testcases_failed = 0
ffi.cdef
[[ 
  void *malloc(size_t size);
  void free(void *ptr);
  void *memset(void *str, int c, size_t n);
]]

local failed_testcases = {}

function increment_failed_mkcol(index, v, str)
  print("testcase name :"..v.name)
  print("qtype: "..v.qtype)
  
  print("reason for failure "..str)
  number_of_testcases_failed = number_of_testcases_failed + 1
  table.insert(failed_testcases,index)

end

function print_result() 
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


function handle_category1(index, v, status, ret)
  print(ret)
  if status ~= false then
    increment_failed_mkcol(index, v, "Mk_col function does not return status = false")
    return nil
  end
  
  if v.output_regex == nil then
    increment_failed_mkcol(index, v, "MK_Col : Output regex not given in category1 testcases")
    return nil
  end
  
  
  local a, b, err = plstring.splitv(ret,':')
  err = plstring.strip(err) 
  
  -- trimming whitespace
  local error_msg = plstring.strip(v.output_regex) -- check it can be used from utils.
  local count = plstring.count(err, error_msg)
  if count > 0 then
    number_of_testcases_passed = number_of_testcases_passed + 1 
  else
    increment_failed_load(index, v, "testcase category1 failed , actual and expected error message does not match")
    print("actual output:"..err)
    print("expected output:"..error_msg)
  
  end

end

function handle_category2(index, v, status, ret)
  print(ret)
  if status ~= true then
    increment_failed_mkcol(index, v, "Mk_col function does not return status = true")
    return nil
  end
  
  if type(ret) ~= 'Column' then
    increment_failed_mkcol(index, v, "Mk_col function does not return Column")
    return nil
  end
  
  
  for i=1,ret:length() do  
    local result = ret:get_element(i-1)
    local ctype =  g_qtypes[ret:fldtype()]["ctype"]
    local str = ffi.cast(ctype.." *",result)
    local final_result = str[0]
    local is_float = ret:fldtype() == "F4" or ret:fldtype() == "F8"
    -- to handle the extra decimal values put in case of Float
    --[[if is_float then
      final_result = 10 * final_result
      final_result = math.ceil(final_result)
      final_result = final_result / 10
    end
    --]]
    --print(str[0] , v.input[i])
    if final_result ~= v.input[i] then
      increment_failed_mkcol(index, v, "Mk_col input output mismatch input = "..v.input[i]..
        " output = "..str[0])
      return nil
    end
    
  end
  
  number_of_testcases_passed = number_of_testcases_passed + 1
  print("Testing successful ", v.name)
  
end
