-- ------------------------------------------------------------------------------------
-- Creates closure for dictionary, so that dictionary can be treated as separate entity
-- ------------------------------------------------------------------------------------
require 'util'
require 'parser'

function newDictionary(dictName)
  
  if(dictName == nil or dicName == "") then
    error("Dictionary name should not be empty")
    return nil
  end
  
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
      if(textExists) then 
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
  
  local saveToFile = function(filePath)
    file = io.open (filePath, "w")
    io.output(file);
    local separator = ",";
    
    for k,v in pairs(self.textToNumber) do 
      local s = escapeCSV(k) .. separator  .. v
      -- print("S is : " .. s)
      -- store the line in the file
       io.write(s, "\n")
     end    
  end

  -- Using Naive approach for reading currently, with the assumption that file will be in correct format 
  local readFromFile = function(filePath)
    for line in io.lines(filePath) do 
      local entry= ParseCSVLine(line,',')
      -- each entry is the form string, number
      self.textToNumber[entry[1]] = entry[2]
      self.numberToText[entry[2]] = entry[1]
    end  
      
  end
  
  local retFunction = {
      addWithCondition = addWithCondition,
      getStringByNumber = getStringByNumber , 
      getNumberByString = getNumberByString, 
      isTextExists = isTextExists, 
      saveToFile = saveToFile,
      readFromFile = readFromFile
  }              
    --put newly created dictionary into global variable
  
  _G["Q_DICTIONARIES"][dictName] = retFunction
  return retFunction 
  
end

