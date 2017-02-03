package.path = package.path .. ";../lua/?.lua"

luaunit = require('luaunit')
require "dictionary"

test_dictionary = {}

function test_dictionary:setUp()
  -- all created dictionaries are stored inside this global variables,
  _G["Q_DICTIONARIES"] = {} 
end

function test_dictionary:tearDown()
end


function test_dictionary:test_create() 
  local dictionary = new_dictionary("testDictionary")
  luaunit.assertNotNil(dictionary)
  luaunit.assertIsTable(dictionary)
end

function test_dictionary:test_create_null_name_error()
  luaunit.assertError(new_dictionary)
  luaunit.assertErrorMsgContains("Dictionary name should not be empty", new_dictionary ) 
end

function test_dictionary:test_add()
  local dictionary = new_dictionary("D1")
  local entry1 = dictionary.add_with_condition("Entry1", false)
  local entry2 =  dictionary.add_with_condition("Entry2")
  
  luaunit.assertNumber(entry1)
  luaunit.assertNumber(entry2)
  luaunit.assertEquals("Entry1", dictionary.get_string_by_number(entry1))
  luaunit.assertEquals("Entry2", dictionary.get_string_by_number(entry2))
  luaunit.assertEquals(entry1, dictionary.get_number_by_string("Entry1"))
  luaunit.assertEquals(entry2, dictionary.get_number_by_string("Entry2"))  
end

function test_dictionary:testAddNil()
  local dictionary = new_dictionary("D1")
  luaunit.assertError(dictionary.add_with_condition, "")
  luaunit.assertErrorMsgContains("Cannot add nil or empty string in dictionary", dictionary.add_with_condition, "")
  luaunit.assertErrorMsgContains("Cannot add nil or empty string in dictionary", dictionary.add_with_condition, "", false)
  luaunit.assertErrorMsgContains("Cannot add nil or empty string in dictionary", dictionary.add_with_condition, "", true)  
end

function test_dictionary:testAddMultipleWithAddFalse()  
  local dictionary = new_dictionary("D1")
  local entry1 = dictionary.add_with_condition("Entry1", false)
   
  luaunit.assertNumber(entry1)
  luaunit.assertErrorMsgContains("Text already exists in dictionary", dictionary.add_with_condition, "Entry1", false)  
end

function test_dictionary:testAddMutipleWithAddTrue()
  local dictionary = new_dictionary("D1")
  local entry1 = dictionary.add_with_condition("Entry1", true)
  local entry2 = dictionary.add_with_condition("Entry1", true)
  
  luaunit.assertNumber(entry1)
  luaunit.assertNumber(entry2)
  luaunit.assertEquals(entry1,entry2)
end

function test_dictionary:testStoreDictionary()
  local dictionary = new_dictionary("D1")
  dictionary.add_with_condition("Entry1")
  dictionary.add_with_condition("Entry2")
  dictionary.save_to_file("./serializedD1")
  
  local f = io.open("./serializedD1", "r")
  local line1 = f:read("*l")
  local line2 = f:read("*line")
  local line3 = f:read("*line")
  luaunit.assertEquals(line1, "Entry1,1")
  luaunit.assertEquals(line2, "Entry2,2")
  luaunit.assertNil(line3)      
  
  f:close()
  os.remove("./serializedD1")
end

function test_dictionary:testReadDictionaryFromFile()
  local dictionary = new_dictionary("D1")
  dictionary.add_with_condition("Entry1")
  dictionary.add_with_condition("Entry2")
  dictionary.save_to_file("./serializedD2")
  
  local restored_dictionary = new_dictionary("D2")
  restored_dictionary.restore_from_file("./serializedD2")
  
  local val = restored_dictionary.get_number_by_string("Entry1")
  
  luaunit.assertEquals( restored_dictionary.get_string_by_number(1), "Entry1")
  luaunit.assertEquals( restored_dictionary.get_number_by_string("Entry2"), 2)
  
  os.remove("./serializedD2")
end



os.exit( luaunit.LuaUnit.run() )
