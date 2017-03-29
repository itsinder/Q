
local plstring = require 'pl.stringx'
local plfile = require 'pl.path'
require 'C_to_txt'

local number_of_testcases_passed = 0
local number_of_testcases_failed = 0

function print_result() 
  print("-----------------------------------")
  print("No of successfull testcases ",number_of_testcases_passed)
  print("No of failure testcases     ",number_of_testcases_failed)
  print("-----------------------------------")
end

-- this function checks whether the output regex is present or not
-- it also checks the status returned by load.
-- for category 1 and category6, if status is false then only testcase will succeed
-- for category 2, category 3, category 4 and category 5
-- if status is true then only testcase will succeed

function handle_output_regex(status, v, flag)
  local output
  if flag then status = status else status = not status end
  -- in category 1 , status = status , flag = true . if status is true, testcase should fail
  -- in category 2,  status = not status, flag = false, if status is false, testcase should fail
  if status then
    print("testcase failed , incorrect status value")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  
  -- output_regex should be present in map_metadata, 
  -- else testcase should fail
  if v.output_regex == nil then
    print("testcase failed , output regex nil")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end  
  
  output = v.output_regex
  return output
end
  
-- this function handle testcases where error messages are expected output 
function handle_category1(status, ret, v)
  --print(ret)
  print(v.meta)
  local output = handle_output_regex(status, v, true)
  if output == nil then return end
  
  -- ret is of format <filepath>:<line_number>:<error_msg>
  -- get the actual error message from the ret
  local a, b, err = plstring.splitv(ret,':')
  err = plstring.strip(err) 
  
  -- trimming whitespace
  local error_msg = plstring.strip(output) -- check it can be used from utils.
  
  print("actual output:"..err)
  print("expected output:"..error_msg)
  -- check this line can be skipped with the duplicate line below
  if error_msg == err then
    number_of_testcases_passed = number_of_testcases_passed + 1 
  else
    print("testcase category1 failed , actual and expected error message does not match")
    number_of_testcases_failed = number_of_testcases_failed + 1
  end
end


-- this function handle testcases where table of columns are expected output 
-- in this table, only one column is present
function handle_category2(status, ret, v, output_category3)
  
  local output

  if v then
    print(v.meta)
    if type(ret) ~= "table" then
      print("testcase category2 failed , output of load is not a table")
      number_of_testcases_failed = number_of_testcases_failed + 1
      return nil
    end
    output = handle_output_regex(status, v, false)
    ret = ret[1]
  else
    output = output_category3
  end
  
  if output == nil then return end
  
  if type(output) ~= "table" then
    print("testcase category2 failed , output regex is not a table")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  
  if type(ret) ~= "Column" then
    print("testcase category2 failed , output of load is not a column")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  --print(ret[1]:length())
  --print(#output)
  if ret:length() ~= #output then
    print("testcase category2 failed , length of Column and output regex does not match")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  
  for i=1,#output do
    local status, result = pcall(convert_c_to_txt,ret,i)
    if status == false then
      print("testcase category2 failed "..result)
      number_of_testcases_failed = number_of_testcases_failed + 1
      return nil
    end
    local is_SC = ret:fldtype() == "SC"    -- if field type is SC , then pass field size, else nil
    local is_SV = ret:fldtype() == "SV"    -- if field type is SV , then get value from dictionary
    
    local is_string = is_SC or is_SV
    if not is_string then 
      result = tonumber(result)
    end
    
    if result ~= output[i] then 
      print("testcase category2 failed , result="..tonumber(result).." output["..i.."]="..output[i])
      number_of_testcases_failed = number_of_testcases_failed + 1
      return nil
    end
  end
  number_of_testcases_passed = number_of_testcases_passed + 1 
  return 1
end

-- this function handle testcases where table of columns are expected output 
-- in this table, multiple columns are present
-- handle_category2 function is reused
-- it is called in loop for every column
function handle_category3(status, ret, v)
  
  print(v.meta)
  local output = handle_output_regex(status, v, false)
  if output == nil then return end
  
  if type(output) ~= "table" and type(ret) ~= "table" then
    print("testcase category3 failed , output regex and output of load is not a table")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  
  if #output ~= #ret then
    print("testcase category3 failed , output regex length is not equal to  output of load ")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  
  for i=1,#output do
    --print(type(ret[i]))
    local ret = handle_category2(status, ret[i], nil, output[i])
    if not ret then return nil end
    number_of_testcases_passed = number_of_testcases_passed - 1
  end
  number_of_testcases_passed = number_of_testcases_passed + 1
end

-- check the length of bin files in this testcase 
function handle_category4(status, ret, v)
  print(v.meta)
  local output = handle_output_regex(status, v, false)
      
  if output == nil then return end
  
  if type(output) ~= "table" and type(ret) ~= "table" then
    print("testcase category4 failed , output regex and output of load is not a table")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  local sum = {}
  for i=1,#ret do
    if type(ret[i]) ~= "Column" then
      print("testcase category4 failed , output of load is not a column")
      number_of_testcases_failed = number_of_testcases_failed + 1
      return nil
    end
    sum[i] = ret[i]:length() * ret[i]:sz()
    if sum[i] ~= output[i] then
      print("testcase category4 failed , size of each column not matching with output regex")
      number_of_testcases_failed = number_of_testcases_failed + 1
      return nil
    end
  end
  number_of_testcases_passed = number_of_testcases_passed + 1
end

-- check whether the null file is present if has_null is true and csv file has no null values
-- if null file present , then load_csv api should delete that file
function handle_category5(status, ret, v)
  print(v.meta)
  local output = handle_output_regex(status, v, false)
      
  if output == nil then return end
  
  if type(ret) ~= "table" then
    print("testcase category5 failed , output of load is not a table")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end
  
  for i=1,#ret do
    if type(ret[i]) ~= "Column" then
      print("testcase category5 failed , output of load is not a column")
      number_of_testcases_failed = number_of_testcases_failed + 1
      return nil
    end
  end
  
  local is_present = plfile.isfile(_G["Q_DATA_DIR"].."_col2_nn")
  if is_present then
    print("testcase category5 failed , null file still present in data directory")
    number_of_testcases_failed = number_of_testcases_failed + 1
    return nil
  end

  number_of_testcases_passed = number_of_testcases_passed + 1
end

-- in this testcase , invalid environment values are set
function handle_input_category6(input_regex)
  
  if input_regex == 1 then _G["Q_DATA_DIR"] = nil end
  if input_regex == 2 then _G["Q_DATA_DIR"] = "./invalid_dir" end
  if input_regex == 3 then _G["Q_META_DATA_DIR"] = nil end
  if input_regex == 4 then _G["Q_META_DATA_DIR"] = "./invalid_dir" end
  
end

-- in this testcase , error messages are compared . 
-- so handle_category1 function is reused
function handle_category6(status, ret, v)
  --print(v.meta)
  handle_category1(status, ret, v)
end