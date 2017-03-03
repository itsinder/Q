require 'utils'
local lu = require('luaunit')


function test_preprocess_bool_values()
  local metadata_table = { 
                            { name = "col1", type ="SV",dict = "D1", dict_exists = "False", add=true, null=true },
                            { name = "col2", type = "I4", null = "true" } 
                         }
  preprocess_bool_values(metadata_table, "null", "dict_exists", "add")
  lu.assertEquals(type(metadata_table[1]["dict_exists"]), "boolean")
  lu.assertEquals(metadata_table[1]["dict_exists"],  false)  
end

function test_preprocess_bool_values_error()
  local metadata_table = { 
                            { name = "col1", type ="SV",dict = "D1", dict_exists = "dummy_value", add=true, null=true },
                            { name = "col2", type = "I4", null = "true" } 
                         }
  lu.assertError(preprocess_bool_values,metadata_table, "null", "dict_exists", "add")  
end


os.exit( lu.LuaUnit.run() )
