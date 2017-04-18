local Dictionary = require "dictionary"
local plstring = require 'pl.stringx'
local plfile = require 'pl.path'

local no_of_success = 0
local no_of_failure = 0
local failed_testcases = {}

local T = dofile("map_dictionary.lua")
  _G["Q_DICTIONARIES"] = {}


function increment_failed_load(index, v, str)
  print("testcase name :"..v.name)
  print("Meta file: "..v.meta)
  
  print("reason for failure ::"..str)
  no_of_failure = no_of_failure + 1
  table.insert(failed_testcases,index)
  
  print("\n-----------------Meta Data File------------\n")
  os.execute("cat /home/pragati/Desktop/Q/UTILS/test/test_metadata/"..v.meta) 
  print("\n--------------------------------------------\n")
  
end

function handle_category1(index, ret, metadata)
  if type(ret) == "Dictionary" then
    no_of_success = no_of_success + 1 
  else
    increment_failed_load(index, metadata, "testcase failed : in category 1 : Return type not Dictionary")
    return nil
  end
end

function handle_category2(index, ret, metadata)
    local status, add_err = pcall(ret.add,"")
    local a, b, err = plstring.splitv(add_err,':')
    err = plstring.strip(err) 
    
    local expected = metadata.output_regex
    local count = plstring.count(err, expected )
  
    if count > 0 then
      no_of_success = no_of_success + 1 
    else
      increment_failed_load(index, metadata, "testcase failed : in category 2 : Error msg not matched with output_regex")
      return nil
    end
end

function handle_category3(index, ret, metadata)
  ret:add("entry1")
  ret:add("entry2")
  ret:add("entry3")
  ret:add("entry4")
  ret:add("entry5")
  local dict_size = ret:get_size()
  
  if dict_size == 5 then
    no_of_success = no_of_success + 1 
  else
    increment_failed_load(index, metadata, "testcase failed : in category 3 : Not added entries in dictionary properly")
    return nil
  end
end

function handle_category4(index, ret, metadata)
  ret:add("String1")
  ret:add("String2")
  local index1 = ret:get_index_by_string("String1")
  local index2 = ret:get_index_by_string("String2")
  
  if index1 == 1 and index2 == 2 then
     no_of_success = no_of_success + 1 
  else
    increment_failed_load(index, metadata, "testcase failed : in category 4 : Invalid index entry")
    return nil
  end
end

function handle_category5(index, ret, metadata)
  ret:add("entry1")
  ret:add("entry2")
  local string1 = ret:get_string_by_index(1)
  local string2 = ret:get_string_by_index(2)
  
  if string1 == "entry1" and string2 == "entry2" then
    no_of_success = no_of_success + 1 
  else
    increment_failed_load(index, metadata, "testcase failed : in category 5 : Invalid string entry")
    return nil
  end
end

function handle_category6(index, ret, metadata)
  ret:add("entry1")
  ret:add("entry2")
  ret:add("entry3")
  local dict_size = ret:get_size()
  
  if dict_size == 3 then
    no_of_success = no_of_success + 1 
  else
    increment_failed_load(index, metadata, "testcase failed : in category 6 : Invalid size of dictionary")
    return nil
  end
end


function print_results()  
  local str
  
  str = "-----------Dictionary testcases results for LOAD_CSV---------------\n"
  str = str.."No of successfull testcases "..no_of_success.."\n"
  str = str.."No of failure testcases     "..no_of_failure.."\n"
  str = str.."-----------------------------------\n"
  str = str.."Testcases failed are     \n"
  for k,v in ipairs(failed_testcases) do
    str = str..v.."\n"
  end
  str = str.."Run bash test_dictionary.sh <testcase_number> for details\n\n"
  str = str.."-----------------------------------\n"
  print(str)
  local file = assert(io.open("nightly_build_dictionary.txt", "w"), "Nighty build file open error")
  assert(io.output(file), "Nightly build file write error")
  assert(io.write(str), "Nightly build file write error")
  assert(io.close(file), "Nighty build file close error")
  
end

local handle_function = {}
-- to test whether return type is Dictionary
handle_function["category1"] = handle_category1
-- checking of invalid dict add to a dictionary
handle_function["category2"] = handle_category2
-- checking of valid dict add to a dictionary
handle_function["category3"] = handle_category3
-- checking valid get index from a dictionary
handle_function["category4"] = handle_category4
-- checking valid get string from a dictionary
handle_function["category5"] = handle_category5
-- checking valid get size of a dictionary
handle_function["category6"] = handle_category6


for i, m in ipairs(T) do
  if arg[1]~= nil and tonumber(arg[1])~=i then goto skip end
  _G["Q_DICTIONARIES"] = {}
  print(i,"Testing : " .. m.name)
  local M = dofile("test_metadata/"..m.meta)
  local x = Dictionary(M.dict)
  local ret = assert(Dictionary(M.dict))
  if handle_function[m.category] then
    handle_function[m.category](i,ret, m)
  end
  ::skip::
end

print_results()