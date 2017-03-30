
local plstring = require 'pl.stringx'
local Vector = require 'Vector'
local Column = require 'Column'
require 'load_csv'
require 'print_csv'

local number_of_testcases_passed = 0
local number_of_testcases_failed = 0

local failed_testcases = {}

function increment_failed(index, str)
  print(str)
  number_of_testcases_failed = number_of_testcases_failed + 1
  table.insert(failed_testcases,index)
end

function handle_category1(index, v, csv_file,ret, status)
  print(v.meta) 
  --print(status)
  if not status then
    increment_failed(index, "testcase failed: in category1, status should be true")
    return nil
  end
  
  local actual_file_content = file.read("test_data/"..v.data)
  local expected_file_content = file.read(csv_file)
  --print(actual_file_content)
  --print(expected_file_content)
  if actual_file_content ~= expected_file_content then
     increment_failed(index, "testcase failed: input and output csv file does not match")
     return nil
  end
  number_of_testcases_passed = number_of_testcases_passed + 1
end

function handle_category2(index, v, csv_file, ret, status)
  print(v.name) 
  
  if status or v.output_regex==nil then
    increment_failed(index, "testcase failed: in category2, status should be false")
    return nil
  end
  
  local actual_output = ret
  local expected_output = v.output_regex
  
  local a, b, err = plstring.splitv(actual_output,':')
  err = plstring.strip(err) 
  --print("Actual error:"..err)
  --print("Expected error:"..expected_output)
  if err ~= expected_output then
     increment_failed(index, "testcase failed: in category2, actual and expected error does  not match")
     return nil
  end
  number_of_testcases_passed = number_of_testcases_passed + 1
end


function handle_input_category4()
  local v1 = Vector{field_type='I4', field_size = 4,chunk_size = 8,
    filename="./bin/I4.bin",  
  }
  return { where = v1 }
end


function handle_input_category3()
  local v1 = Vector{field_type='B1', field_size = 1/8,chunk_size = 8,
    filename="./bin/B1.bin",  
  }
  return { where = v1 }
end

function handle_category4(index, v, csv_file, ret, status)
  print(v.name) 
  
  if status then
    increment_failed(index, "testcase failed: in category4, status should be false")
    return nil
  end
  
  local expected_output = v.output_regex
   
  local a, b, err = plstring.splitv(ret,':')
  err = plstring.strip(err) 
  --print("Actual error:"..err)
  --print("Expected error:"..expected_output)
  
  if err ~= expected_output then
     increment_failed(index, "testcase failed: in category 4, actual and expected error does  not match")
     return nil
  end
   number_of_testcases_passed = number_of_testcases_passed + 1
end

function handle_category3(index, v, csv_file, ret, status)
  print(v.name) 
  
  if not status then
    increment_failed(index, "testcase failed: in category3, status should be true")
    return nil
  end
  
  local expected_file_content = file.read(csv_file)
  
  --print(expected_file_content)
  --print(v.output_regex)
  if v.output_regex ~= expected_file_content then
     increment_failed(index, "testcase failed: in category 3, actual and expected output does  not match")
     return nil
  end
  
  number_of_testcases_passed = number_of_testcases_passed + 1
end


function handle_category5(index, v, csv_file, ret, status)
  print(v.name) 
  
  if not status then
    increment_failed(index, "testcase failed: in category5, status should be true")
    return nil
  end
  
  local expected_file_content = file.read(csv_file)
  
  --print(expected_file_content)
  --print(v.output_regex)
  if v.output_regex ~= expected_file_content then
     increment_failed(index, "testcase failed: in category 5, actual and expected output does  not match")
     return nil
  end
  
  number_of_testcases_passed = number_of_testcases_passed + 1
end

function handle_category6(index, v, M)
  print(v.name)
  
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
    increment_failed(index, "testcase failed: in category 6, input and output bin files does  not match")
    return nil
  end
  
  number_of_testcases_passed = number_of_testcases_passed + 1
end

function print_testcases_result()
  
  print("-----------------------------------")
  print("No of successfull testcases ",number_of_testcases_passed)
  print("No of failure testcases     ",number_of_testcases_failed)
  print("-----------------------------------")
  print("Testcases failed are     ")
  for k,v in ipairs(failed_testcases) do
    print(v)
  end
  
  
end
