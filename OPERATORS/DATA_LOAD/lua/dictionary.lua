-- ------------------------------------------------------------------------------------
-- Creates closure for dictionary, so that dictionary can be treated as separate entity
-- ------------------------------------------------------------------------------------
require 'util'
require 'parser'

-- --------------------------------------------------
-- New dictionary can be created by calling : 
-- local d1 = newDictionary(dictionaryName)
-- Every new dictionary adds its reference to itself in the global variable called  _G["Q_DICTIONARIES"][dictName] . 
-- This can be used at the time shutdown time, to iterate over all dictionary and persist it to the disk. 
-- ----------------------------------------------
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
               
  -- private function, used to get next number, which should be assigned to new strings being added into dictionary               
  local getNextNumber = function()
    self.currIndex = self.currIndex + 1
    return self.currIndex
  end
                        
  -- If the text exists in the dictionary
  local isStringExists = function(text) 
      if self.textToNumber[text] ~= nil then
        return true 
      else 
        return false
      end
  end
  
  -- private function to add text into dictionary
  local put = function(text)
    -- if text does not exist then only add
    -- if(isStringExists(text) ~= true) then 
      local randomValue = getNextNumber()
      self.textToNumber[text] = randomValue
      self.numberToText[randomValue] = text
    -- end
  end
  
  -- Given a number, if that number exists in dictionary then the string corresponding to that number is returned, null otherwise
  local getStringByNumber = function(index)
    local num = self.numberToText[index]
    return num
  end
          
  -- Given a string, if that string  exists in dictionary then the corresponding number to that string, null otherwise        
  local getNumberByString = function(text) 
    return self.textToNumber[text]
  end
  
  -- --------------------------------------------------
  -- Adds the string into dictionary and returns number corresponding to the string 
  --     addIfExists = true (default) :  If string exists in the dictionary then returns number corresponding to that string 
  --                                      otherwise adds the string into dictionary and returns the number at which string was added
  --     addIfExists = false : If string exists in the dictionary then returns -1, 
  --                                        otherwise adds the string into dictionary and returns the number at which string was added
  -- -------------------------------------------------
  
  local addWithCondition = function(text, addIfExists)
  
    if(text == nil or text == "") then error("Cannot add nil or empty string in dictionary") end
  
    -- default to true for addIfExists condition
    if(addIfExists == nil) then addIfExists = true end
    
    
    local textExists = isStringExists(text)
    if(addIfExists) then 
      if(textExists) then 
        return getNumberByString(text)
      else
        put(text)
        return getNumberByString(text)
      end
    else
      if(textExists) then 
        error("Text already exists in dictionary")
      else
        put(text)
        return getNumberByString(text)
      end
    end
    
  end
  
  
  -- --------------------------------------
  -- save all dictionary content to the file specified by the filePath.   
  --     Currently only one table textToNumber is dumped into file as csv content. 
  --     CSV writing is the very basic function, which just escapes (‘ “ ) and writes the output. This function can be evolved if required
  -- -------------------------------------- 
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
    file:close() 
  end

  -- ----------------------------------------------
  -- reads the dictionary back from the file 
  --   It will read each line from the csv file and add entry in both table (textToNumber and numberToText ) 
  -- -------------------------------------------
  
  local readFromFile = function(filePath)
    for line in io.lines(filePath) do 
      local entry= ParseCSVLine(line,',')
      -- each entry is the form string, number
      
      self.textToNumber[entry[1]] = tonumber(entry[2])
      self.numberToText[tonumber(entry[2])] = entry[1]
    end  
  end
 
  
  local retFunction = {
      addWithCondition = addWithCondition,
      getStringByNumber = getStringByNumber , 
      getNumberByString = getNumberByString, 
      isStringExists = isStringExists, 
      saveToFile = saveToFile,
      readFromFile = readFromFile
  }              
  
  --put newly created dictionary into global variable
  _G["Q_DICTIONARIES"][dictName] = retFunction
  return retFunction 
  
end

