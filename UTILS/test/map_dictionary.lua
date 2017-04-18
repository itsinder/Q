--[[ Guidelines for adding new testcases in this file
File : map_dictionary.lua
In this file, all the testcases are written in the format
name = <name of testcase>, category = <category_number>, meta = <meta file>, output_regex = <expected_output>
They are added as a row in the below LUA table.
category1 - to check return type is Dictionary
category2 - error code testcase
category3 - adding valid entry into dictionary 
category4 - getting valid index of a string from dictionary 
category5 - getting valid string stored at particular index from dictionary 
category6 - getting valid dictionary size
For all the error codes , refer to UTILS/lua/error_codes.lua
In case, you want to add a test case with a new error code, add the error code in the UTILS/lua/error_codes.lua file.
--]]
require("error_code")

return { 
      -- checking the return of dict is dictionary
      { name = "create dictionary", category = "category1", meta = "test_create.lua" },
      
      -- checking of invalid dict add to a dictionary by comparing the output_regex error message
      { name = "test invalid(nil) dict add ", category = "category2", meta = "test_add_nil.lua", 
        output_regex = g_err.ADD_NIL_EMPTY_ERROR_IN_DICT  },
      
      -- checking of adding a valid dictionary entries to a dictionary
      { name = "test valid dict add", category = "category3", meta = "test_add_dict.lua" },
      
      -- checking of valid get index from a dictionary
      { name = "test valid get index", category = "category4", meta = "test_get_index.lua" },
      
      -- checking of valid get string from a dictionary
      { name = "test valid get string", category = "category5", meta = "test_get_string.lua" },
      
      -- checking valid get size from a dictionary
      { name = "test valid get size", category = "category6", meta = "test_getsize.lua" },
      
      
}