local rootdir = os.getenv("Q_SRC_ROOT")
local plstring = require 'pl.stringx'
local plfile = require 'pl.path'
require 'C_to_txt'

local number_of_testcases_passed = 0
local number_of_testcases_failed = 0

local failed_testcases = {}

function increment_failed_load(index, v, str)
  print("testcase name :"..v.name)
  print("Meta file: "..v.meta)
  print("csv file: "..v.data)
  
  print("reason for failure "..str)
  number_of_testcases_failed = number_of_testcases_failed + 1
  table.insert(failed_testcases,index)
  
  print("\n-----Meta Data File------\n")
  os.execute("cat "..rootdir.."/OPERATORS/LOAD_CSV/test/testcases/test_metadata/"..v.meta)
  print("\n\n-----CSV File-------\n")
  os.execute("cat "..rootdir.."/OPERATORS/LOAD_CSV/test/testcases/test_data/"..v.data)
  print("\n--------------------\n")
  
end

function print_result() 
  print("-----------------------------------")
  print("No of successfull testcases ",number_of_testcases_passed)
  print("No of failure testcases     ",number_of_testcases_failed)
  print("-----------------------------------")
  print("Testcases failed are     ")
  for k,v in ipairs(failed_testcases) do
    print(v)
  end
  print("Run bash test_load_csv.sh <testcase_number> for details\n\n")
     print("-----------------------------------")
end

-- this function checks whether the output regex is present or not
-- it also checks the status returned by load.
-- for category 1 and category6, if status is false then only testcase will succeed
-- for category 2, category 3, category 4 and category 5
-- if status is true then only testcase will succeed

function handle_output_regex(index, status, v, flag, category)
  local output
  
  if flag then status = status else status = not status end
  -- in category 1 , status = status , flag = true . if status is true, testcase should fail
  -- in category 2,  status = not status, flag = false, if status is false, testcase should fail
  if status then
    print("status is ",status) 
    increment_failed_load(index, v, "testcase failed : in "..category.." , incorrect status value")
    return nil
  end
  
  -- output_regex should be present in map_metadata, 
  -- else testcase should fail
  if v.output_regex == nil then
    increment_failed_load(index, v, "testcase failed : in "..category.." , output regex nil")
    return nil
  end  
  
  output = v.output_regex
  return output
end
  
-- this function handle testcases where error messages are expected output 
function handle_category1(index, status, ret, v)
  print(ret)
  print(v.name)
  local output = handle_output_regex(index, status, v, true, "category1")
  if output == nil then return end
  
  -- ret is of format <filepath>:<line_number>:<error_msg>
  -- get the actual error message from the ret
  local a, b, err = plstring.splitv(ret,':')
  err = plstring.strip(err) 
  
  -- trimming whitespace
  local error_msg = plstring.strip(output) -- check it can be used from utils.
  
  -- check this line can be skipped with the duplicate line below
  if error_msg == err then
    number_of_testcases_passed = number_of_testcases_passed + 1 
  else
    increment_failed_load(index, v, "testcase category1 failed , actual and expected error message does not match")
    print("actual output:"..err)
    print("expected output:"..error_msg)
  
  end
end


-- this function handle testcases where table of columns are expected output 
-- in this table, only one column is present
function handle_category2(index, status, ret, v, output_category3, v_category3)
  print(ret)
  local output

  if v then
    print(v.name)
    if type(ret) ~= "table" then
      increment_failed_load(index, v, "testcase failed: in category2 , output of load is not a table")
      return nil
    end
    output = handle_output_regex(index, status, v, false, "category2")
    ret = ret[1]
  else
    v = v_category3
    output = output_category3
  end
  
  if output == nil then return end
  
  if type(output) ~= "table" then
    increment_failed_load(index, v, "testcase failed: in category2 , output regex is not a table")
    return nil
  end
  
  if type(ret) ~= "Column" then
    increment_failed_load(index, v, "testcase failed: in category2 , output of load is not a column")
    return nil
  end
  --print(ret[1])
  --print(ret:length())
  --print(#output)
  if ret:length() ~= #output then
    increment_failed_load(index, v, "testcase failed: in category2 , length of Column and output regex does not match")
    return nil
  end
  
  for i=1,ret:length() do
    local status, result = pcall(convert_c_to_txt,ret,i)
    
    if status == false then
      increment_failed_load(index, v, "testcase failed: in category2 "..result)
      return nil
    end
    local is_SC = ret:fldtype() == "SC"    -- if field type is SC , then pass field size, else nil
    local is_SV = ret:fldtype() == "SV"    -- if field type is SV , then get value from dictionary
    
    local is_string = is_SC or is_SV
    if not is_string then 
      result = tonumber(result)
    end
    --print(result, output[i])
    -- if result is nil, then set to empty string
    if result == nil then result = "" end
    if result ~= output[i] then 
      increment_failed_load(index, v, "testcase category2 failed , \nresult="..result.." \noutput["..i.."]="..output[i].."\n")
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
function handle_category3(index, status, ret, v)
  print(ret)
  print(v.name)
  local output = handle_output_regex(index, status, v, false, "category3")
  if output == nil then return end
  
  if type(output) ~= "table" and type(ret) ~= "table" then
    increment_failed_load(index, v, "testcase failed: in category3 , output regex and output of load is not a table")
    return nil
  end
  
  if #output ~= #ret then
    increment_failed_load(index, v, "testcase failed: in category3 , output regex length is not equal to  output of load ")
    return nil
  end
  
  for i=1,#output do
    --print(type(ret[i]))
    local ret = handle_category2(index, status, ret[i], nil, output[i], v)
    if not ret then return nil end
    number_of_testcases_passed = number_of_testcases_passed - 1
  end
  number_of_testcases_passed = number_of_testcases_passed + 1
end

-- check the length of bin files in this testcase 
function handle_category4(index, status, ret, v)
  print(ret)
  print(v.name)
  local output = handle_output_regex(index, status, v, false, "category4")
      
  if output == nil then return end
  
  if type(output) ~= "table" and type(ret) ~= "table" then
    increment_failed_load(index, v, "testcase failed: in category4 , output regex and output of load is not a table")
    return nil
  end
  local sum = {}
  for i=1,#ret do
    if type(ret[i]) ~= "Column" then
      increment_failed_load(index, v, "testcase failed: in category4 , output of load is not a column")
      return nil
    end
    sum[i] = ret[i]:length() * ret[i]:sz()
    if sum[i] ~= output[i] then
      increment_failed_load(index, v, "testcase failed: in category4 , size of each column not matching with output regex")
      return nil
    end
  end
  number_of_testcases_passed = number_of_testcases_passed + 1
end

-- check whether the null file is present if has_null is true and csv file has no null values
-- if null file present , then load_csv api should delete that file
function handle_category5(index, status, ret, v)
  print(ret)
  print(v.name)
  local output = handle_output_regex(index, status, v, false, "category5")
      
  if output == nil then return end
  
  if type(ret) ~= "table" then
    increment_failed_load(index, v, "testcase failed: in category5 , output of load is not a table")
    return nil
  end
  
  for i=1,#ret do
    if type(ret[i]) ~= "Column" then
      increment_failed_load(index, v, "testcase failed: in category5 , output of load is not a column")
      return nil
    end
  end
  
  local is_present = plfile.isfile(_G["Q_DATA_DIR"].."_col2_nn")
  if is_present then
    increment_failed_load(index, v, "testcase failed: in category5 , null file still present in data directory")
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
  if input_regex == 5 then _G["Q_DICTIONARIES"] = nil end
  
end

-- in this testcase , error messages are compared . 
-- so handle_category1 function is reused
function handle_category6(index, status, ret, v)
  --print(v.name)
  handle_category1(index, status, ret, v)
end