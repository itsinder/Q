require 'globals'
require 'parser'
require 'dictionary'
require 'QCFunc'

local ffi = require("ffi") 

-- ----------------
-- load( "CSV file to load", "meta data", "Global Metadata") 
-- Loads the CSV file and stores in the Q internal format
-- 
-- Remaining Things : 
-- 1. Global metdata is not being used currently
-- 2. Dictionary Handling is remaining
-- 3. Null values are curently not handled
-- 4. 
-- ----------------

function load( csv_file, M , G)

  local fpTable = {}
  
  -- open file for each field defined in metdata
  for i, metadata in ipairs(M) do 
    -- TODO : Handle case where metadata name is empty
    fpTable[i] = create(metadata.name)
    
    -- TODO : 
    -- create dictionaries if required.. upfront for only one type based on metdata
    -- This needs to be more generalized.. It should be driven by q_types stored in globals
    -- as below code is, so that new types like varchar can be handled easilty .. ideally without code cahnge
    
    local fieldType = metadata["type"];
    if( fieldType == "varchar") then 
        -- print("Field Type is varchar.. now chehck fields realted to dictionary") 
      
        -- { name = "colName", type ="varchar",dict = "D1", is_dict = true, add=true}
        -- read field realted to dictionary from the medata 
        local dictName = metadata["dict"]
        local isDict = metadata["is_dict"] or false  -- default value is false, dictionary does not exist.. create one
        local addNewValue = metadata["add"] or true  -- default value is true, add null values
          
        if(isDict == true) then
          local dict = _G["Q_DICTIONARIES"][dictName] 
          if(dict == nil) then 
              print("Dictionary does not exist. Aborting the operation") 
              return -1
          end 
        else
          local dict = _G["Q_DICTIONARIES"][dictName]
          if(dict ~= nil) then 
              print("Dictionary with the same name exists, cannot create new dictionary")
          end
          
          -- create new dictory and set it in the globals
          dict = {}
          _G["Q_DICTIONARIES"][dictName] = newDictionary() 
        end
        
    end
    
    
  end
  
  -- TODO : Check if file:open makes more sense then io.lines 
  for line in io.lines(csv_file) do
    
    local res= ParseCSVLine(line,',')       -- call to parse to parse the line of csv file
    
    for i, metadata in ipairs(M) do 
      if metadata.name == "" then 
        -- Skip this line
      else
        
        local val = res[i]  
        local dataTypeShortCode = metadata["type"];
        local funName = g_qtypes[dataTypeShortCode]["txt_to_ctype"]
        local sizeOfData = g_qtypes[dataTypeShortCode]["width"]
        local dictionary = g_qtypes[dataTypeShortCode]["dictionary"]
        
        if(dictionary ~= nil and dictionary == true) then 
          -- print("Dictionary conversion is required for this field")
          local dictName = metadata["dict"]
          -- local isDict = metadata["is_dict"] or false  
          local addNewValue = metadata["add"] or true 
          
          local dict = _G["Q_DICTIONARIES"][dictName]
          local retNumber = dict.addWithCondition(val, addNewValue)
          
          if(retNumber < 0 ) then 
            print("Error: value exists in the dictionary, cannot add new one, aborting operation")
            return -1 
          end
          
          -- now change the value to index instead of string
          val = tostring(retNumber)
          
        end
        
        local cVal = convertTextToCValue(funName, val, sizeOfData)
        write(fpTable[i],cVal, sizeOfData) 
        
      end
    end
  end
  
  -- close all the files
  for i, metadata in ipairs(M) do 
      close(fpTable[i])
  end

end
