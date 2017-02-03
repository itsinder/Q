package.path = package.path .. ";../lua/?.lua"

luaunit = require('luaunit')
require "dictionary"

TestDictionary = {}

function TestDictionary:setUp()
  -- all created dictionaries are stored inside this global variables,
  _G["Q_DICTIONARIES"] = {} 
end

function TestDictionary:tearDown()
end


function TestDictionary:testCreate() 
  local dictionary = newDictionary("testDictionary")
  luaunit.assertNotNil(dictionary)
  luaunit.assertIsTable(dictionary)
end

function TestDictionary:testCreateNullNameError()
  luaunit.assertError(newDictionary)
  luaunit.assertErrorMsgContains("Dictionary name should not be empty", newDictionary ) 
end

function TestDictionary:testAdd()
  local D1 = newDictionary("D1")
  local e1 = D1.addWithCondition("Entry1", false)
  local e2 =  D1.addWithCondition("Entry2")
  
  luaunit.assertNumber(e1)
  luaunit.assertNumber(e2)
  luaunit.assertEquals("Entry1", D1.getStringByNumber(e1))
  luaunit.assertEquals("Entry2", D1.getStringByNumber(e2))
  luaunit.assertEquals(e1, D1.getNumberByString("Entry1"))
  luaunit.assertEquals(e2, D1.getNumberByString("Entry2"))  
end

function TestDictionary:testAddNil()
  local D1 = newDictionary("D1")
  luaunit.assertError(D1.addWithCondition, "")
  luaunit.assertErrorMsgContains("Cannot add nil or empty string in dictionary", D1.addWithCondition, "")
  luaunit.assertErrorMsgContains("Cannot add nil or empty string in dictionary", D1.addWithCondition, "", false)
  luaunit.assertErrorMsgContains("Cannot add nil or empty string in dictionary", D1.addWithCondition, "", true)  
end

function TestDictionary:testAddMultipleWithAddFalse()  
  local D1 = newDictionary("D1")
  local e1 = D1.addWithCondition("Entry1", false)
   
  luaunit.assertNumber(e1)
  luaunit.assertErrorMsgContains("Text already exists in dictionary", D1.addWithCondition, "Entry1", false)  
end

function TestDictionary:testAddMutipleWithAddTrue()
  local D1 = newDictionary("D1")
  local e1 = D1.addWithCondition("Entry1", true)
  local e2 = D1.addWithCondition("Entry1", true)
  
  luaunit.assertNumber(e1)
  luaunit.assertNumber(e2)
  luaunit.assertEquals(e1,e2)
end

function TestDictionary:testStoreDictionary()
  local D1 = newDictionary("D1")
  D1.addWithCondition("Entry1")
  D1.addWithCondition("Entry2")
  D1.saveToFile("./serializedD1")
  
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

function TestDictionary:testReadDictionaryFromFile()
  local D1 = newDictionary("D1")
  D1.addWithCondition("Entry1")
  D1.addWithCondition("Entry2")
  D1.saveToFile("./serializedD2")
  
  local D2 = newDictionary("D2")
  D2.readFromFile("./serializedD2")
  
  local val = D2.getNumberByString("Entry1")
  
  luaunit.assertEquals( D2.getStringByNumber(1), "Entry1")
  luaunit.assertEquals( D2.getNumberByString("Entry2"), 2)
  
  os.remove("./serializedD2")
end



os.exit( luaunit.LuaUnit.run() )
