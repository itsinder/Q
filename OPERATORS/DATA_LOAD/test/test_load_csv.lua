package.path = package.path .. ";../lua/?.lua"

local lu = require('luaunit')
require 'load_csv'
require 'environment'
require 'pl'


test_load_csv = {}
local test_input_dir = "./test_data/"

-- command setting which needs to be done for all test-cases
function test_load_csv:setUp()
  --set environment variables for test-case
  _G["Q_DATA_DIR"] = "./test_data/out/"
  _G["Q_META_DATA_DIR"] = "./test_data/metadata/"
  _G["Q_DICTIONARIES"] = {}
  
  dir.makepath(_G["Q_DATA_DIR"])
  dir.makepath(_G["Q_META_DATA_DIR"])
end

-- commond cleanup for all testcases
function test_load_csv:tearDown()
  -- clear the output directory 
  dir.rmtree(_G["Q_DATA_DIR"])
  dir.rmtree(_G["Q_META_DATA_DIR"])
end

-- ----------------

-- Test Case Start ---------------

-- ######## Environment variables #### ---------------------
function test_load_csv:test_data_dir_env_nil()
  local temp = _G["Q_DATA_DIR"]  
  _G["Q_DATA_DIR"] = nil
  lu.assertErrorMsgContains("Please make sure that Q_DATA_DIR points to correct directory", load ,  test_input_dir .."sample.csv", { { name = "col1", type = "I4" }})
  _G["Q_DATA_DIR"] = temp -- reset so that tear down function works correctly
end

function test_load_csv:test_data_dir_env_invalid()
  local temp = _G["Q_DATA_DIR"] 
  _G["Q_DATA_DIR"] = "./invalid_dir"
  lu.assertErrorMsgContains("Please make sure that Q_DATA_DIR points to correct directory", load , test_input_dir .. "sample.csv", { { name = "col1", type = "I4" }})
  _G["Q_DATA_DIR"] = temp
end
  
function test_load_csv:test_metdata_dir_env_nil()
  local temp = _G["Q_META_DATA_DIR"] 
  _G["Q_META_DATA_DIR"] = nil
  lu.assertErrorMsgContains("Please make sure that Q_META_DATA_DIR points to correct directory", load , test_input_dir .. "sample.csv", { { name = "col1", type = "I4" }})
  _G["Q_META_DATA_DIR"] = temp
end

function test_load_csv:test_metdata_dir_env_invalid()
  local temp = _G["Q_META_DATA_DIR"]
  _G["Q_META_DATA_DIR"] = "./invalid_dir"
  lu.assertErrorMsgContains("Please make sure that Q_META_DATA_DIR points to correct directory", load , test_input_dir .. "sample.csv", { { name = "col1", type = "I4" }})
  _G["Q_META_DATA_DIR"] = temp
end


-- ######## Metadata ##### ------------

function test_load_csv:test_nil_metadata()
  lu.assertErrorMsgContains("Metadata should not be nil", load , test_input_dir .. "sample.csv", metadata)
end

function test_load_csv:test_metadata_is_not_table()
  lu.assertErrorMsgContains("Metadata type should be table", load, test_input_dir .. "sample.csv","string_data" )
  lu.assertErrorMsgContains("Metadata type should be table", load, test_input_dir .. "sample.csv", 1 )
end

-- name and type are mandatory attribute of metadata which should be present in all metadata
function test_load_csv:test_metadata_int_float_missing_req_attribute()
  lu.assertErrorMsgContains("name cannot be null", load, test_input_dir .. "sample.csv", { { name_type = "col1", type = "I4" }} )
  lu.assertErrorMsgContains("type cannot be null", load, test_input_dir .. "sample.csv", { { name = "col1", type_error = "F4" }} )
  lu.assertErrorMsgContains("name cannot be null", load, test_input_dir .. "sample.csv", { { dummy_field = "" }} )
end

-- for SV fields dictionary is the mandatory attribute
function test_load_csv:test_SV_missing_required_attribute()
  lu.assertErrorMsgContains("dict cannot be null", load, test_input_dir .. "sample.csv", {{ name = "col1", type ="SV", is_dict = true, add=true}} )
  lu.assertErrorMsgContains("is_dict cannot be null", load, test_input_dir .. "sample.csv", {{ name = "col1", type ="SV", dict = "D1", add=true}} )
  lu.assertErrorMsgContains("add cannot be null", load, test_input_dir .. "sample.csv", {{ name = "col1", type ="SV", dict = "D1", is_dict = true }} )
end

function test_load_csv:test_duplicate_column_names()
lu.assertErrorMsgContains("duplicate column name is not allowed", load, test_input_dir .. "sample.csv",
   {{ name = "col1", type = "I4" }, 
   { name = "col1", type = "I2" }} )
end


function test_load_csv:test_type_not_in_qtypes()
  lu.assertErrorMsgContains("type contains invalid q type", load, test_input_dir .. "sample.csv", {{ name = "col1", type ="I3", null="false"}} )
end


-- ###### File content #########
function test_load_csv:test_nil_file()
  local metadata = { { name = "empid", null="true", type = "I4" } }
  lu.assertErrorMsgContains("Please make sure that csv_file_path is correct", load , nil, metadata)
end

function test_load_csv:test_file_not_exist()
  local metadata = { { name = "empid", null="true", type = "I4" },
              { name = "yoj", type ="I2" },
              { name = "empname", type ="SV",dict = "D1", is_dict = false, add=true} }
  local csv_file_path = test_input_dir .. "some_nonexistent_file"
  
  lu.assertError(load, csv_file_path, metadata)
  _G["Q_DICTIONARIES"] = {} -- clear out the global dictionary, so that second operation does not fail  
  lu.assertErrorMsgContains("Please make sure that csv_file_path is correct", load, csv_file_path, metadata )     
end

function test_load_csv:test_file_is_empty()
  lu.assertErrorMsgContains("File should not be empty", load , test_input_dir .. "empty_file.csv", { { name = "col1", type = "I4" }})
end


function test_load_csv:test_double_quotes_mismatch()
  local metadata = { { name = "col1", type ="SV",dict = "D1", is_dict = false, add=true},
              { name = "col2", type ="I4" }}
  local csv_file_path = test_input_dir .. "bad_quote_mismatch.csv"
  --make sure error is reported by program
  lu.assertError(load, csv_file_path, metadata )
end

function test_load_csv:test_eoln_in_data()
  local metadata = { { name = "col1", type ="SV",dict = "D1", is_dict = false, add=true}}
  local num_records = 4
  local csv_file_path = test_input_dir .. "file_with_eol.csv"
  local ret = load ( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_col1"), num_records * 4)
end

function test_load_csv:test_last_char_file_not_eol()
  local metadata = { { name = "col1", type ="SV",dict = "D1", is_dict = false, add=true}}
  local csv_file_path = test_input_dir .. "last_char_not_eol.csv"
  local num_records = 4
  local ret = load ( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_col1"), num_records * 4)
end


function test_load_csv:test_load_valid_escape_char()
  local metadata = { { name = "col1", type ="SV",dict = "D1", is_dict = false, add=true}}
  local csv_file_path = test_input_dir .. "valid_escape.csv"
  local num_records = 4
  local ret = load ( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_col1"), num_records * 4)
end

function test_load_csv:test_load_missing_escape_char()
  local metadata = { { name = "col1", type ="SV",dict = "D1", is_dict = false, add=true}}
  local csv_file_path = test_input_dir .. "missing_escape_char.csv"
  lu.assertErrorMsgContains("contains invalid data", load, csv_file_path, metadata )
end


function test_load_csv:test_column_is_more()
  local metadata = { { name = "col1", type = "I4", null ="true" },
              { name = "col2", type ="I2" },
              { name = "col3", type ="SV",dict = "D1", is_dict = false, add=true},
              { name = "extrac_column", type ="I2" }}
  local csv_file_path = test_input_dir .. "I2_I2_SV_3_4.csv"
  lu.assertErrorMsgContains("Column count does not match with count of column in metadata", load, csv_file_path, metadata )

end

function test_load_csv:test_column_is_less()
  local csv_file_path = test_input_dir .. "I2_I2_SV_3_4.csv"
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
              { name = "empname", type ="SV",dict = "D1", is_dict = false, add=true} }
              
  local csv_file_path = test_input_dir .. "I2_I2_SV_3_4.csv"
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table")     
end

function test_load_csv:test_valid_load_bin_file_size()
  local file_path, actual_size, expected_size
  local metadata = {{ name = "empid", null="true", type = "I4" },
              { name = "yoj", type ="I2" },
              { name = "empname", type ="SV",dict = "D1", is_dict = false, add=true} }
  local csv_file_path = test_input_dir .. "I2_I2_SV_3_4.csv"
  local num_records = 4
  
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_empid"), num_records * 4)
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_yoj"), num_records * 2)
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_empname"), num_records* 4)
end

function test_load_csv:test_nil_value_in_not_nil_field()
  local csv_file_path = test_input_dir .. "I4_2_null.csv"
  local metadata = {{ name = "col1", type = "I4", null ="false" }, { name = "col2", type = "I4", null ="false" }}
  lu.assertErrorMsgContains("Null value found in not null field", load, csv_file_path, metadata )
end

function test_load_csv:test_nil_value_in_not_nil_field_2_column()
  local csv_file_path = test_input_dir .. "I4_2_4_null.csv"
  local metadata = { { name = "col1", type = "I4", null ="false" }, { name = "col2", type = "I4", null ="false" }}
  lu.assertErrorMsgContains("Null value found in not null field", load, csv_file_path, metadata )
end

function test_load_csv:test_no_nil_value_in_nil_field()
  local csv_file_path = test_input_dir .. "I4_valid.csv"
  local num_records = 4
  local metadata = { { name = "col1", type = "I4", null ="true" }}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_col1"), num_records * 4)
end

function test_load_csv:test_valid_I1()
  local csv_file_path = test_input_dir .. "I1_valid.csv"
  local num_records = 4
  local metadata = { { name = "col1", type = "I1", null ="true" }}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_col1"), num_records * 1)
  
  local vector = ret[1].get_vector()
  local x, x_size = vector:chunk(0)
    
  lu.assertEquals(convert_c_to_txt("I1", x , 0 ), "-128")
  lu.assertEquals(convert_c_to_txt("I1", x , 1 ), "0")
  lu.assertEquals(convert_c_to_txt("I1", x , 2 ), "127")
  lu.assertEquals(convert_c_to_txt("I1", x , 3 ), "11")  
end

function test_load_csv:test_valid_I2()
  local csv_file_path = test_input_dir .. "I2_valid.csv"
  local num_records = 4
  local metadata = { { name = "col2", type = "I2", null ="true" }}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_col2"), num_records * 2)
  
  local vector = ret[1].get_vector()
  local x, x_size = vector:chunk(0)
    
  lu.assertEquals(convert_c_to_txt("I2", x , 0 ), "-32768")
  lu.assertEquals(convert_c_to_txt("I2", x , 1 ), "0")
  lu.assertEquals(convert_c_to_txt("I2", x , 2 ), "32767")
  lu.assertEquals(convert_c_to_txt("I2", x , 3 ), "11")  
  
end

function test_load_csv:test_valid_I4()
  local csv_file_path = test_input_dir .. "I4_valid.csv"
  local num_records = 4
  local metadata = { { name = "col1", type = "I4", null ="true" }}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_col1"), num_records * 4)

  local vector = ret[1].get_vector()
  local x, x_size = vector:chunk(0)
    
  lu.assertEquals(convert_c_to_txt("I4", x , 0 ), "-2147483648")
  lu.assertEquals(convert_c_to_txt("I4", x , 1 ), "0")
  lu.assertEquals(convert_c_to_txt("I4", x , 2 ), "2147483647")
  lu.assertEquals(convert_c_to_txt("I4", x , 3 ), "11")  

end

function test_load_csv:test_valid_I8()
  local csv_file_path = test_input_dir .. "I8_valid.csv"
  local num_records = 4
  local metadata = { { name = "col1", type = "I8", null ="true" }}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_col1"), num_records * 8)

  local vector = ret[1].get_vector()
  local x, x_size = vector:chunk(0)
    
  lu.assertEquals(convert_c_to_txt("I8", x , 0 ), "-9223372036854775808")
  lu.assertEquals(convert_c_to_txt("I8", x , 1 ), "0")
  lu.assertEquals(convert_c_to_txt("I8", x , 2 ), "9223372036854775807")
  lu.assertEquals(convert_c_to_txt("I8", x , 3 ), "11")  


end

function test_load_csv:test_valid_F4()
  local csv_file_path = test_input_dir .. "F4_valid.csv"
  local num_records = 4
  local metadata = { { name = "col1", type = "F4", null ="true" }}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_col1"), num_records * 4)

  local vector = ret[1].get_vector()
  local x, x_size = vector:chunk(0)
    
  lu.assertEquals(convert_c_to_txt("F4", x , 0 ), "-922337203685477.58")
  lu.assertEquals(convert_c_to_txt("F4", x , 1 ), "0")
  lu.assertEquals(convert_c_to_txt("F4", x , 2 ), "922337203685477.58")
  lu.assertEquals(convert_c_to_txt("F4", x , 3 ), "11")  
end

function test_load_csv:test_valid_F8()
  local csv_file_path = test_input_dir .. "F8_valid.csv"
  local num_records = 4
  local metadata = { { name = "col1", type = "F8", null ="true" }}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_col1"), num_records * 8)
  
  local vector = ret[1].get_vector()
  local x, x_size = vector:chunk(0)
    
  lu.assertEquals(convert_c_to_txt("F4", x , 0 ), "-922337203685477.58")
  lu.assertEquals(convert_c_to_txt("F4", x , 1 ), "0")
  lu.assertEquals(convert_c_to_txt("F4", x , 2 ), "922337203685477.58")
  lu.assertEquals(convert_c_to_txt("F4", x , 3 ), "11")  
  
end

function test_load_csv:test_valid_fix_size_string()
  local csv_file_path = test_input_dir .. "SV_valid.csv"
  local num_records = 4
  local size_of_string = 16
  local metadata = { { name = "col1", type="SC" , size = 16}}
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_col1"), num_records * size_of_string)

  local vector = ret[1].get_vector()
  local x, x_size = vector:chunk(0)
    
  lu.assertEquals(convert_c_to_txt("SC", x , 0*size_of_string, 16), "Sample")
  lu.assertEquals(convert_c_to_txt("SC", x , 1*size_of_string, 16), "String")
  lu.assertEquals(convert_c_to_txt("SC", x , 2*size_of_string, 16), "For")
  lu.assertEquals(convert_c_to_txt("SC", x , 3*size_of_string, 16), "Varchar")    
end

function test_load_csv:test_fix_size_string_more_data_than_size()
  local csv_file_path = test_input_dir .. "SV_valid.csv"
  local metadata = { { name = "col1", type="SC" , size = 5}}
  lu.assertErrorMsgContains("string greater than allowed size", load, csv_file_path, metadata )     
end

function test_load_csv:test_valid_SV()
  local csv_file_path = test_input_dir .. "SV_valid.csv"
  local num_records = 4
  local metadata = { { name = "col1", type ="SV",dict = "D1", is_dict = false, add=true} }
  local ret = load( csv_file_path, metadata )
  lu.assertEquals(type(ret),"table") 
  lu.assertEquals(path.getsize(_G["Q_DATA_DIR"].. "_col1"), num_records * 4)

  local vector = ret[1].get_vector()
  local x, x_size = vector:chunk(0)
  
  lu.assertEquals(convert_c_to_txt("I4", x , 0 ), "1")
  lu.assertEquals(convert_c_to_txt("I4", x , 1 ), "2")
  lu.assertEquals(convert_c_to_txt("I4", x , 2 ), "3")
  lu.assertEquals(convert_c_to_txt("I4", x , 3 ), "4")  
  
  local D1 = _G["Q_DICTIONARIES"]["D1"]
    
  lu.assertEquals(D1.get_string_by_number(1), "Sample")
  lu.assertEquals(D1.get_string_by_number(2), "String")
  lu.assertEquals(D1.get_string_by_number(3), "For")
  lu.assertEquals(D1.get_string_by_number(4), "Varchar")    
end

function test_load_csv:test_int_overflow()
  lu.assertErrorMsgContains("Invalid data found", load, test_input_dir .. "I1_overflow.csv", { { name = "col1", type = "I1", null ="true" }} )
  lu.assertErrorMsgContains("Invalid data found", load, test_input_dir .. "I2_overflow.csv", { { name = "col1", type = "I2", null ="true" }} )
  lu.assertErrorMsgContains("Invalid data found", load, test_input_dir .. "I4_overflow.csv", { { name = "col1", type = "I4", null ="true" }} )
  lu.assertErrorMsgContains("Invalid data found", load, test_input_dir .. "I8_overflow.csv", { { name = "col1", type = "I8", null ="true" }} )
end

function test_load_csv:test_string_in_int_data()
  lu.assertErrorMsgContains("Invalid data", load, test_input_dir .. "bad_string_in_I1.csv", { { name = "col1", type = "I1", null ="true" }} )
end


function test_load_csv:test_whole_row_nil()
  local csv_file_path = test_input_dir .. "I4_2_null.csv"
  local metadata = { { name = "col1", type="SC" , size = 15, null = true},{ name = "col2", type = "F8", null ="true" } }
  -- there should not be any error during load
  local res = load(csv_file_path, metadata)  
end

function test_load_csv:test_nil_data_I4()
  local csv_file_path = test_input_dir .. "I4_2_4_null.csv"
  local metadata = { { name = "col1", type="I4" ,null = true},{ name = "col2", type = "I4", null ="true" } }
  -- there should not be any error during load
  local ret = load(csv_file_path, metadata)    

  local vector = ret[1].get_nn_vector()
  local x, x_size = vector:chunk(0)
    
  lu.assertEquals(convert_c_to_txt("I1", x , 0 ), "1")
  lu.assertEquals(convert_c_to_txt("I1", x , 1 ), "1")
  lu.assertEquals(convert_c_to_txt("I1", x , 2 ), "1")
  lu.assertEquals(convert_c_to_txt("I1", x , 3 ), "0")  

  local vector_col2 = ret[2].get_nn_vector()
  local y, y_size = vector_col2:chunk(0)
  lu.assertEquals(convert_c_to_txt("I1", y , 0 ), "1")
  lu.assertEquals(convert_c_to_txt("I1", y , 1 ), "1")
  lu.assertEquals(convert_c_to_txt("I1", y , 2 ), "0")
  lu.assertEquals(convert_c_to_txt("I1", y , 3 ), "1")  
end

function test_load_csv:test_nil_data_SV()
  local csv_file_path = test_input_dir .. "I4_2_null.csv"
  local metadata = { { name = "col1", type ="SV",dict = "D1", is_dict = false, add=true, null=true },{ name = "col2", type = "I4", null ="true" } }
  -- there should not be any error during load
  local ret = load(csv_file_path, metadata)      

  local vector = ret[1].get_nn_vector()
  local x, x_size = vector:chunk(0)
    
  lu.assertEquals(convert_c_to_txt("I1", x , 0 ), "1")
  lu.assertEquals(convert_c_to_txt("I1", x , 1 ), "1")
  lu.assertEquals(convert_c_to_txt("I1", x , 2 ), "0")
  lu.assertEquals(convert_c_to_txt("I1", x , 3 ), "1")  

  local vector_col2 = ret[2].get_nn_vector()
  local y, y_size = vector_col2:chunk(0)
  lu.assertEquals(convert_c_to_txt("I1", y , 0 ), "1")
  lu.assertEquals(convert_c_to_txt("I1", y , 1 ), "0")
  lu.assertEquals(convert_c_to_txt("I1", y , 2 ), "1")
  lu.assertEquals(convert_c_to_txt("I1", y , 3 ), "1")  
end

function test_load_csv:test_nil_data_file_deletion()
  local csv_file_path = test_input_dir .. "I4_valid.csv"
  local metadata = { { name = "col2", type = "I4", null ="true" } }
  -- there should not be any error during load
  local res = load(csv_file_path, metadata)      
  lu.assertFalse(path.exists(_G["Q_DATA_DIR"].. "_nn_col1"))  
end




-- ---- Test cases ---------

--[[
TODO : 
o) Can we specify integer in hex format?
o) Can we specify floating point in exponent format?
--]]
--[[
print("#####")
  _G["Q_DATA_DIR"] = "./test_data/"
  _G["Q_META_DATA_DIR"] = "./test_data/"
  _G["Q_DICTIONARIES"] = {}
print("####")
--]]

os.exit( lu.LuaUnit.run() )


