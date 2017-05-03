local Dictionary = require "dictionary"
local plstring = require 'pl.stringx'
local plfile = require 'pl.path'
local utils = require 'utils'

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

-- this function checks whether after passing valid metadata
-- the return type of Dictionary is Dictionary or not

function handle_category1(index, ret, metadata)
  if type(ret) == "Dictionary" then
    no_of_success = no_of_success + 1
    return true
  else
    increment_failed_load(index, metadata, "testcase failed : in category 1 : Return type not Dictionary")
    return false
  end
end

-- this function handle the testcase where
-- error messages are expected output
-- if null or empty string is passed to add dictionary function 
-- it should give an error

function handle_category2(index, ret, metadata)
    local status, add_err = pcall(ret.add,metadata.input)
    local a, b, err = plstring.splitv(add_err,':')
    err = plstring.strip(err) 
    
    local expected = metadata.output_regex
    local count = plstring.count(err, expected )
  
    if count > 0 then
      no_of_success = no_of_success + 1
      return true
    else
      increment_failed_load(index, metadata, "testcase failed : in category 2 : Error message not matched with output_regex")
      return false
    end
end

-- this function checks whether valid string entries are added in dictionary 
-- and checking if get_size gives a valid size of a dictionary

function handle_category3(index, ret, metadata)
  
  for i=1, #metadata.input do
    ret:add(metadata.input[i])
  end

  local dict_size = ret:get_size()
  if dict_size == metadata.dict_size then
    no_of_success = no_of_success + 1
    return true
  else
    increment_failed_load(index, metadata, "testcase failed : in category 3 : Not added entries in dictionary properly")
    return false
  end
end

-- this function checks whether a correct index 
-- of a valid string is returned from a dictionary

function handle_category4(index, ret, metadata)
  for i=1, #metadata.input do
    ret:add(metadata.input[i])
  end
  
  for i=1, #metadata.input do
    if ret:get_index_by_string(metadata.input[i]) ~= metadata.output_regex[i] then
      increment_failed_load(index, metadata, "testcase failed : in category 4 : Invalid index entry")
      return false
    end
  end
  
  no_of_success = no_of_success + 1
  return true
end

-- this function checks whether a correct string 
-- of a valid index is returned from a dictionary

function handle_category5(index, ret, metadata)
  for i=1, #metadata.input do
    ret:add(metadata.input[i])
  end
  
  for i=1, #metadata.input do
    if ret:get_string_by_index(i) ~=  metadata.input[i] then
      increment_failed_load(index, metadata, "testcase failed : in category 4 : Invalid string entry")
      return false
    end
  end
  
  no_of_success = no_of_success + 1
  return true
end



function print_results()  
  local str
  
  str = "-----------Dictionary testcases results for LOAD_CSV---------------\n"
  str = str.."No of successfull testcases "..no_of_success.."\n"
  str = str.."No of failure testcases     "..no_of_failure.."\n"
  str = str.."---------------------------------------------------------------\n"
  if #failed_testcases > 0 then
    str = str.."Testcases failed are     \n"
    for k,v in ipairs(failed_testcases) do
      str = str..v.."\n"
    end
    str = str.."Run bash test_dictionary.sh <testcase_number> for details\n\n"
    str = str.."-------------------------------------------------------------\n"
  end 
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
-- and checking valid get size of a dictionary
handle_function["category3"] = handle_category3
-- checking valid get index from a dictionary
handle_function["category4"] = handle_category4
-- checking valid get string from a dictionary
handle_function["category5"] = handle_category5


local function calling_dictionary(i ,m)
  -- print(i,"Testing : " .. m.name)
  local M = dofile("test_metadata/"..m.meta)
  local x = Dictionary(M.dict)
  local result
  local ret = assert(Dictionary(M.dict))
  if handle_function[m.category] then
    result = handle_function[m.category](i,ret, m)
  else
    fns["increment_failed_load"](i, m, "Handle function for "..m.category.." is not defined in handle_category.lua")
    result = false
  end
   utils["testcase_results"](m, "test_dictionary.lua", "Dictionary", "Unit Test", result)
end



for i, m in ipairs(T) do
  if arg[1]~= nil and tonumber(arg[1])~=i then goto skip end
  
  -- for testcase 5 and 7 testcase 4 should be executed for the dictionary to in existence 
  if arg[1]~= nil and tonumber(arg[1])==5 or tonumber(arg[1])==7 then
    local no_of_tc = {}
    if tonumber(arg[1])==5 then no_of_tc = { 4, 5 } end
    if tonumber(arg[1])==7 then no_of_tc = { 4, 7 } end
    for j=1,#no_of_tc do
      i = no_of_tc[j]
      m = T[i]
      calling_dictionary(i, m)
    end
    goto skip
  end
  -- normal calling of all the testcases
  calling_dictionary(i, m)
  
  ::skip::
end

print_results()