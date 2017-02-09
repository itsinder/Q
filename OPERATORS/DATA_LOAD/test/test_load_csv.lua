package.path = package.path .. ";../lua/?.lua"

local lu = require('luaunit')
require 'load_csv'
require 'environment'


test_load_csv = {}
local test_input_dir = "./test_data/"

-- command setting which needs to be done for all test-cases
function test_load_csv:setUp()
  --set environment variables for test-case
  _G["Q_DATA_DIR"] = "./test_data/out/"
  _G["Q_META_DATA_DIR"] = "./test_data/metadata/"
  _G["Q_DICTIONARIES"] = {}
  
  test_load_csv:create_directory(_G["Q_DATA_DIR"])
  test_load_csv:create_directory(_G["Q_META_DATA_DIR"])
end

-- commond cleanup for all testcases
function test_load_csv:tearDown()
  -- clear the output directory 
  test_load_csv:empty_directory(_G["Q_DATA_DIR"])
  test_load_csv:empty_directory(_G["Q_META_DATA_DIR"])
end


-- Utility functions used in this testcase -----
function test_load_csv:create_directory(dir_path)
  os.execute("mkdir " .. dir_path)
end

function test_load_csv:empty_directory(dir_path)
  os.execute('rm -rd "'..dir_path..'"')
end

function test_load_csv:calculate_file_size(file_path)
  local file =  io.open(file_path, "r")
  local current = file:seek()      -- get current position
  local size = file:seek("end")    -- get file size
  file:seek("set", current)        -- restore position
  file:close()
  return size
end
-- ----------------



-- Test Case Start ---------------

-- ######## Environment variables #### ---------------------
function test_load_csv:test_data_dir_env_nil()
  local temp = _G["Q_DATA_DIR"]  
  _G["Q_DATA_DIR"] = nil
  lu.assertErrorMsgContains("Please make sure that Q_DATA_DIR points to correct directory", load ,  test_input_dir .."sample_3_4.csv", { { name = "col1", type = "I4" }})
  _G["Q_DATA_DIR"] = temp -- reset so that tear down function works correctly
end

function test_load_csv:test_data_dir_env_invalid()
  local temp = _G["Q_DATA_DIR"] 
  _G["Q_DATA_DIR"] = "./invalid_dir"
  lu.assertErrorMsgContains("Please make sure that Q_DATA_DIR points to correct directory", load , test_input_dir .. "sample_3_4.csv", { { name = "col1", type = "I4" }})
  _G["Q_DATA_DIR"] = temp
end
  
function test_load_csv:test_metdata_dir_env_nil()
  local temp = _G["Q_META_DATA_DIR"] 
  _G["Q_META_DATA_DIR"] = nil
  lu.assertErrorMsgContains("Please make sure that Q_META_DATA_DIR points to correct directory", load , test_input_dir .. "sample_3_4.csv", { { name = "col1", type = "I4" }})
  _G["Q_META_DATA_DIR"] = temp
end

function test_load_csv:test_metdata_dir_env_invalid()
  local temp = _G["Q_META_DATA_DIR"]
  _G["Q_META_DATA_DIR"] = "./invalid_dir"
  lu.assertErrorMsgContains("Please make sure that Q_META_DATA_DIR points to correct directory", load , test_input_dir .. "sample_3_4.csv", { { name = "col1", type = "I4" }})
  _G["Q_META_DATA_DIR"] = temp
end


-- ######## Metadata ##### ------------

function test_load_csv:test_nil_metadata()
  local csv_file_path = "./test_data/sample_3_4.csv"
  lu.assertErrorMsgContains("Metadata should not be nil", load , csv_file_path, metadata)
end

function test_load_csv:test_metadata_is_not_table()
  lu.assertErrorMsgContains("Please specify correct metadata", load, test_input_dir .. "sample_3_4.csv","string_data" )
  lu.assertErrorMsgContains("Please specify correct metadata", load, test_input_dir .. "sample_3_4.csv", 1 )
end

-- name and type are mandatory attribute of metadata which should be present in all metadata
function test_load_csv:test_metadata_missing_req_attribute()
  lu.assertErrorMsgContains("Please specify correct metadata", load, test_input_dir .. "sample_3_4.csv", { { name_type = "col1", type = "I4" }} )
  lu.assertErrorMsgContains("Please specify correct metadata", load, test_input_dir .. "sample_3_4.csv", { { name = "col1", type_error = "I4" }} )
  lu.assertErrorMsgContains("Please specify correct metadata", load, test_input_dir .. "sample_3_4.csv", { { dummy_field = "" }} )
end

-- for varchar fields dictionary is the mandatory attribute
function test_load_csv:test_varchar_missing_dictionary_attribute()
  lu.assertErrorMsgContains("Please specify correct metadata", load, test_input_dir .. "sample_3_4.csv", {{ name = "col1", type ="varchar", is_dict = true, add=true}} )
end

function test_load_csv:test_type_not_in_qtypes()
  lu.assertErrorMsgContains("Please specify correct metadata", load, test_input_dir .. "sample_3_4.csv", {{ name = "col1", type ="I3", null="false"}} )
end


-- ###### File being loaded #########
function test_load_csv:test_nil_file()
  local metadata = { { name = "empid", null="true", type = "I4" } }
  lu.assertErrorMsgContains("Please make sure that csv_file_path is correct", load , nil, metadata)
end

function test_load_csv:test_file_not_exist()
  local metadata = { { name = "empid", null="true", type = "I4" },
              { name = "yoj", type ="I2" },
              { name = "empname", type ="varchar",dict = "D1", is_dict = false, add=true} }
  local csv_file_path = test_input_dir .. "some_nonexistent_file"
  
  lu.assertError(load, csv_file_path, metadata)
  _G["Q_DICTIONARIES"] = {} -- clear out the global dictionary, so that second operation does not fail  
  lu.assertErrorMsgContains("Please make sure that csv_file_path is correct", load, csv_file_path, metadata )     
end

function test_load_csv:test_file_is_empty()
  lu.assertErrorMsgContains("File should not be empty", load , test_input_dir .. "empty_file.csv", { { name = "col1", type = "I4" }})
end


function test_load_csv:test_double_quotes_mismatch()
  local metadata = { { name = "col1", type ="varchar",dict = "D1", is_dict = false, add=true},
              { name = "col2", type ="I4" }}
  local csv_file_path = test_input_dir .. "bad_quote_mismatch.csv"
  --make sure error is reported by program
  lu.assertError(load, csv_file_path, metadata )
end

function test_load_csv:test_eoln_in_data()
  local metadata = { { name = "col1", type ="varchar",dict = "D1", is_dict = false, add=true}}
  local num_records = 4
  local csv_file_path = test_input_dir .. "file_with_eol.csv"
  local ret = load ( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_col1"), num_records * 4)
end

function test_load_csv:test_last_char_file_not_eol()
  local metadata = { { name = "col1", type ="varchar",dict = "D1", is_dict = false, add=true}}
  local csv_file_path = test_input_dir .. "last_char_not_eol.csv"
  local num_records = 4
  local ret = load ( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_col1"), num_records * 4)
end


function test_load_csv:test_load_valid_escape_char()
  local metadata = { { name = "col1", type ="varchar",dict = "D1", is_dict = false, add=true}}
  local csv_file_path = test_input_dir .. "valid_escape.csv"
  local num_records = 4
  local ret = load ( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_col1"), num_records * 4)
end

function test_load_csv:test_load_missing_escape_char()
  local metadata = { { name = "col1", type ="varchar",dict = "D1", is_dict = false, add=true}}
  local csv_file_path = test_input_dir .. "missing_escape_char.csv"
  lu.assertErrorMsgContains("Invalid CSV data", load, csv_file_path, metadata )
end



-- ######### File Loading #######
function test_load_csv:test_column_is_more()
  local metadata = { { name = "col1", type = "I4", null ="true" },
              { name = "col2", type ="I2" },
              { name = "col3", type ="varchar",dict = "D1", is_dict = false, add=true},
              { name = "extrac_column", type ="I2" }}
  local csv_file_path = test_input_dir .. "sample_3_4.csv"
  lu.assertErrorMsgContains("Column count does not match with count of column in metadata", load, csv_file_path, metadata )

end

function test_load_csv:test_column_is_less()
  local csv_file_path = test_input_dir .. "sample_3_4.csv"
  local metadata = { { name = "col1", type = "I4", null ="true" },
              { name = "col2", type ="I2" }}
  lu.assertErrorMsgContains("Column count does not match with count of column in metadata", load, csv_file_path, metadata )
end

function test_load_csv:test_column_not_same_on_each_line()
  local csv_file_path = test_input_dir .. "bad_col_data_mismatch_each_line.csv"
  local metadata = { { name = "col1", type = "I4", null ="true" },
              { name = "col2", type ="I2" }}
  lu.assertErrorMsgContains("Column count does not match with count of column in metadata", load, csv_file_path, metadata )
end


function test_load_csv:test_load_successfull()
  local metadata = { { name = "empid", null="true", type = "I4" },
              { name = "yoj", type ="I2" },
              { name = "empname", type ="varchar",dict = "D1", is_dict = false, add=true} }
              
  local csv_file_path = test_input_dir .. "sample_3_4.csv"
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table")     
end

function test_load_csv:test_valid_load_bin_file_size()
  local file_path, actual_size, expected_size
  local metadata = {{ name = "empid", null="true", type = "I4" },
              { name = "yoj", type ="I2" },
              { name = "empname", type ="varchar",dict = "D1", is_dict = false, add=true} }
  local csv_file_path = test_input_dir .. "sample_3_4.csv"
  local num_records = 4
  
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_empid"), num_records * 4)
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_yoj"), num_records * 2)
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_empname"), num_records* 4)
end

function test_load_csv:test_nil_value_in_not_nil_field()
  local csv_file_path = test_input_dir .. "sample_null_I4.csv"
  local metadata = { { name = "col1", type = "I4", null ="false" }}
  lu.assertErrorMsgContains("Null value found in not null field", load, csv_file_path, metadata )
end

function test_load_csv:test_nil_value_in_not_nil_field_2_column()
  local csv_file_path = test_input_dir .. "sample_null_2_I4.csv"
  local metadata = { { name = "col1", type = "I4", null ="false" }, { name = "col1", type = "I4", null ="false" }}
  lu.assertErrorMsgContains("Null value found in not null field", load, csv_file_path, metadata )
end

function test_load_csv:test_no_nil_value_in_nil_field()
  local csv_file_path = test_input_dir .. "sample_I4.csv"
  local num_records = 4
  local metadata = { { name = "col1", type = "I4", null ="true" }}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_col1"), num_records * 4)
end


function test_load_csv:test_valid_I1()
  local csv_file_path = test_input_dir .. "sample_I1.csv"
  local num_records = 4
  local metadata = { { name = "col1", type = "I1", null ="true" }}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_col1"), num_records * 1)
end

function test_load_csv:test_valid_I2()
  local csv_file_path = test_input_dir .. "sample_I2.csv"
  local num_records = 4
  local metadata = { { name = "col1", type = "I2", null ="true" }}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_col1"), num_records * 2)
end

function test_load_csv:test_valid_I4()
  local csv_file_path = test_input_dir .. "sample_I4.csv"
  local num_records = 4
  local metadata = { { name = "col1", type = "I4", null ="true" }}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_col1"), num_records * 4)
end

function test_load_csv:test_valid_I8()
  local csv_file_path = test_input_dir .. "sample_I8.csv"
  local num_records = 4
  local metadata = { { name = "col1", type = "I8", null ="true" }}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_col1"), num_records * 8)
end

function test_load_csv:test_valid_fix_size_string()
  local csv_file_path = test_input_dir .. "sample_varchar.csv"
  local num_records = 4
  local metadata = { { name = "col1", type="SC" , size = 16}}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_col1"), num_records * 16)
end

function test_load_csv:test_valid_varchar()
  local csv_file_path = test_input_dir .. "sample_varchar.csv"
  local num_records = 4
  local metadata = { { name = "col1", type ="varchar",dict = "D1", is_dict = false, add=true} }
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_col1"), num_records * 4)
end


function test_load_csv:test_int_overflow()
  lu.assertErrorMsgContains("Invalid data found", load, test_input_dir .. "sample_I1_overflow.csv", { { name = "col1", type = "I1", null ="true" }} )
  lu.assertErrorMsgContains("Invalid data found", load, test_input_dir .. "sample_I2_overflow.csv", { { name = "col1", type = "I2", null ="true" }} )
  lu.assertErrorMsgContains("Invalid data found", load, test_input_dir .. "sample_I4_overflow.csv", { { name = "col1", type = "I4", null ="true" }} )
  --TODO Enable it after overflow issue is fixed 
  -- lu.assertErrorMsgContains("Invalid data found", load, test_input_dir .. "sample_I8_overflow.csv", { { name = "col1", type = "I8", null ="true" }} )
end


function test_load_csv:test_string_in_int_data()
  lu.assertErrorMsgContains("Invalid data", load, test_input_dir .. "bad_string_in_I1.csv", { { name = "col1", type = "I1", null ="true" }} )
end

-- ---- Test cases ---------

--[[
TODO : 

- Fixed size string metadata validation
o) floating point out of range
o) Can we specify integer in hex format?
o) Can we specify floating point in exponent format?
--]]

--[[
print("#####")
  _G["Q_DATA_DIR"] = "./test_data/"
  _G["Q_META_DATA_DIR"] = "./test_data/"
 
  local csv_file_path = test_input_dir .. "sample_varchar.csv"
  local num_records = 4
  local metadata = { { name = "col1", type="SC" , size = 16}}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(test_load_csv:calculate_file_size(_G["Q_DATA_DIR"].. "_col1"), num_records * 8)
print("####")
--]]


os.exit( lu.LuaUnit.run() )


