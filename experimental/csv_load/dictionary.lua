-- ------------------------------------------------------------------------------------
-- Creates closure for dictionary, so that dectionary can be treated as separate entity
-- It will have following methods 
-- put(text) - puts value into dictionary
-- get(index) - get value by index
-- getIndex(text) - gets the index of the value, if it exists in the dictionary, nil otherwise
-- isTextExists(text) - does value exist in dictionary 
-- ------------------------------------------------------------------------------------


function newDictionary()
  -- Two tables are used here, so that bidirectional lookup becomes easy 
  -- and whole table scan is not required for one side
  local self = {
      textToNumber = {},
      numberToText = {},  
      currIndex = 0,
  }
                
  local getNextNumber = function()
    self.currIndex = self.currIndex + 1
    return self.currIndex
  end
                        
  local isTextExists = function(text) 
      if self.textToNumber[text] ~= nil then
        return true 
      else 
        return false
      end
  end
  
  local put = function(text)
    -- if text does not exist then only add
    -- if(isTextExists(text) ~= true) then 
      local randomValue = getNextNumber()
      self.textToNumber[text] = randomValue
      self.numberToText[randomValue] = text
    -- end
  end
  
  local getStringByNumber = function(index)
    return self.numberToText[index]
  end
          
  local getNumberByString = function(text) 
    return self.textToNumber[text]
  end
  
  -- later on, instead of boolean second condition can be made function to make criteria more generic
  local addWithCondition = function(text, addIfExists)
    local textExists = isTextExists(text)
    if(addIfExists) then 
      if(textExsts) then 
        return getNumberByString(text)
      else
        put(text)
        return getNumberByString(text)
      end
    else
      if(textExists) then 
        return -1
      else
        put(text) 
        return getNumberByString(text)
      end
    end
    
  end
                        
  return {
      addWithCondition = addWithCondition,
      getStringByNumber = getStringByNumber , 
      getNumberByString = getNumberByString, 
      isTextExists = isTextExists
  }
  
end



-- test --- 
--[[
d1 = newDictionary()
print(d1.addWithCondition("Pranav"))
print(d1.addWithCondition("Maniar"))
print(d1.addWithCondition("Pranav", false))
print(d1.getStringByNumber(1))
print(d1.getNumberByString("Pranav"))
print(d1.isTextExists("Maniar"))
print(d1.isTextExists("Maniar1"))
--]]
