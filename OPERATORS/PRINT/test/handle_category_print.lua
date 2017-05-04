local plstring = require 'pl.stringx'
local Vector = require 'Vector'
local Column = require 'Column'
local load_csv = require 'load_csv'
local print_csv = require 'print_csv'

local number_of_testcases_passed = 0
local number_of_testcases_failed = 0

local failed_testcases = {}

local fns = {}

fns.increment_failed = function (index, v, str)
  print("testcase name :"..v.name)
  print("Meta file: "..v.meta)
  if v.data then
    print("csv file: "..v.data)
  end
  print("reason for failure "..str)
  number_of_testcases_failed = number_of_testcases_failed + 1
  table.insert(failed_testcases,index)
  --[[
  print("\n-----Meta Data File------\n")
  os.execute("cat "..rootdir.."/OPERATORS/PRINT/test/test_metadata/"..v.meta)
  print("\n\n-----CSV File-------\n")
  os.execute("cat "..rootdir.."/OPERATORS/PRINT/test/test_data/"..v.data)
  print("\n--------------------\n")
  ]]--
end

-- match file1 and file2, return true if success
local file_match = function (file1, file2)
  local actual_file_content = file.read(file1)
  local expected_file_content = file.read(file2)
  --print(actual_file_content)
  --print(expected_file_content)
  if actual_file_content ~= expected_file_content then
     return false
  end
  return true
end

-- original data -> load -> print -> Data A -> load -> print -> Data B. 
-- In this function Data A is matched with Data B 
local check_again = function (index, csv_file, meta)
  local M = dofile("./test_metadata/"..meta)
  -- print(csv_file)
  local status_load, load_ret = pcall(load_csv,csv_file, M)
  if status_load == false then
    fns["increment_failed"](index, v, "testcase failed: in category1, output of load_csv fail in second attempt")
    return false
  end
  
  local status_print, print_ret = pcall(print_csv, load_ret, nil, csv_file..".output")
  if status_print == false then
    fns["increment_failed"](index, v, "testcase failed: in category1, output of print_csv fail in second attempt")
    return false
  end
  
  if file_match(csv_file, csv_file..".output") == false then
    fns["increment_failed"](index, v, "testcase failed: in category1, input and output csv file does not match in second attempt")
    return false
  end
  
  number_of_testcases_passed = number_of_testcases_passed + 1
  return true
end

-- in this category input file to load_csv and output file from print_csv is matched
fns.handle_category1 = function (index, v, csv_file,ret, status)
  --print(v.name) 
  --print(status)
  -- if status returned is false then this testcase has failed
  if not status then
    print(ret)
    fns["increment_failed"](index, v, "testcase failed: in category1, output of print_csv is not success")
    return false
  end
  
  -- print(ret)
  if type(ret) ~= "string" then
    fns["increment_failed"](index, v, "testcase failed: in category1, output of print_csv is not string")
    return false
  end
  
  -- print("output regex = ",v.output_regex)
  if ret ~= v.output_regex then
    fns["increment_failed"](index, v, "testcase failed: in category1, output of print_csv does not match with output_regex")
    return false
  end
  -- match input and output files
  if file_match("test_data/"..v.data, csv_file) == false then
     fns["increment_failed"](index, v, "testcase failed: in category1, input and output csv file does not match")
     return false
  end
  --number_of_testcases_passed = number_of_testcases_passed + 1

  -- original data -> load -> print -> Data A -> load -> print -> Data B. 
  -- In this function Data A is matched with Data B 
  return check_again(index, csv_file, v.meta)
end

-- in this category invalid filter input are given 
-- output expected are error codes as mentioned in UTILS/error_code.lua file
fns.handle_category2 = function (index, v, csv_file, ret, status)
  -- print(v.name) 
  
  if status or v.output_regex==nil then
    fns["increment_failed"](index, v, "testcase failed: in category2, output of print_csv should be false")
    return false
  end
  
  local actual_output = ret
  local expected_output = v.output_regex
  
  -- actual output is of format <filepath>:<line_number>:<error_msg>
  -- get the actual error message from the ret
  local a, b, err = plstring.splitv(actual_output,':')
  -- trimming whitespace if any
  err = plstring.strip(err) 
  --print("Actual error:"..err)
  --print("Expected error:"..expected_output)
  if err ~= expected_output then
     fns["increment_failed"](index, v, "testcase failed: in category2, actual and expected error message does  not match")
     return false
  end
  number_of_testcases_passed = number_of_testcases_passed + 1
  return true
end

-- vector of type I4 is given as filter input for category 4 testcases
fns.handle_input_category4 = function ()
  local v1 = Vector{field_type='I4', field_size = 4,chunk_size = 8,
    filename="./bin/I4.bin",  
  }
  return { where = v1 }
end

-- vector of type B1 is given as filter input for category 3 testcases
fns.handle_input_category3 = function ()
  local v1 = Vector{field_type='B1', field_size = 1/8,chunk_size = 8,
    filename="./bin/B1.bin",  
  }
  return { where = v1 }
end

-- in this category expected output is FILTER_INVALID_FIELD_TYPE
fns.handle_category4 = function (index, v, csv_file, ret, status)
  --print(v.name) 
  
  if status then
    fns["increment_failed"](index, v, "testcase failed: in category4, output of print_csv should be false")
    return false
  end
  
  local expected_output = v.output_regex
   
  local a, b, err = plstring.splitv(ret,':')
  err = plstring.strip(err) 
  --print("Actual error:"..err)
  --print("Expected error:"..expected_output)
  
  if err ~= expected_output then
     fns["increment_failed"](index, v, "testcase failed: in category 4, actual and expected error does  not match")
     return false
  end
   number_of_testcases_passed = number_of_testcases_passed + 1
   return true
end

-- in this testcase bit vector is given as input 
-- the output of csv file will be only those elements 
-- whose bits are set in the bit vector
fns.handle_category3 = function (index, v, csv_file, ret, status)
  -- print(v.name) 
  
  if not status then
    -- print(ret)
    fns["increment_failed"](index, v, "testcase failed: in category3, output of print_csv should be true")
    return false
  end
  
  local expected_file_content = file.read(csv_file)
  
  --print(expected_file_content)
  --print(v.output_regex)
  if v.output_regex ~= expected_file_content then
     fns["increment_failed"](index, v, "testcase failed: in category 3, actual and expected output does  not match")
     return false
  end
  
  number_of_testcases_passed = number_of_testcases_passed + 1
  return true
end

-- in this testcase range filter is given as input
-- the output of print_csv would be only those elements which fall between lower and upper range
fns.handle_category5 = function (index, v, csv_file, ret, status)
  -- print(v.name) 
  
  if not status then
    -- print(ret)
    fns["increment_failed"](index, v, "testcase failed: in category5, output of print_csv should be true")
    return false
  end
  
  local expected_file_content = file.read(csv_file)
  
  --print(expected_file_content)
  --print(v.output_regex)
  if v.output_regex ~= expected_file_content then
     fns["increment_failed"](index, v, "testcase failed: in category 5, actual and expected output does  not match")
     return false
  end
  
  number_of_testcases_passed = number_of_testcases_passed + 1
  return true
end

-- in this testcase, the output csv file from print_csv should be consumable to load_csv
fns.handle_category6 = function (index, v, M)
  -- print(v.name)
  
  local col = Column{field_type='I4', field_size = 4,chunk_size = 8,
    filename="./bin/I4.bin",  
  }
  
  local arr = {col}
  --print_csv(arr,nil,"testcase_consumable.csv")
  local status, print_ret = pcall(print_csv, arr, nil, "testcase_consumable.csv")
  if status then
    local status, load_ret = pcall(load_csv,"testcase_consumable.csv", M)
    --print(status, load_ret)
  end
  --print(M[1].name)
  local filename = _G["Q_DATA_DIR"].."_"..M[1].name
  --print(filename)
  
  local actual_file_content1 = file.read("./bin/I4.bin")
  local actual_file_content2 = file.read(filename)
  if actual_file_content1 ~= actual_file_content2 then  
    fns["increment_failed"](index, v, "testcase failed: in category 6, input and output bin files does  not match")
    return false
  end
  
  number_of_testcases_passed = number_of_testcases_passed + 1
  return true
end

-- this function prints all the result
fns.print_result = function ()
  local str
  str = "----------PRINT TEST CASES RESULT----------------\n"
  str = str.."No of successfull testcases "..number_of_testcases_passed.."\n"
  str = str.."No of failure testcases     "..number_of_testcases_failed.."\n"
  str = str.."--------------------------------------------\n"
  if #failed_testcases > 0 then
    str = str.."Testcases failed are     \n"
    for k,v in ipairs(failed_testcases) do
      str = str..v.."\n"
    end
    str = str.."Run bash test_print_csv.sh <testcase_number> for details\n\n"
    str = str.."------------------------------------------\n"
  end
  print(str)
  local file = assert(io.open("nightly_build_print.txt", "w"), "Nighty build file open error")
  assert(io.output(file), "Nightly build file write error")
  assert(io.write(str), "Nightly build file write error")
  assert(io.close(file), "Nighty build file close error")
  
end

return fns