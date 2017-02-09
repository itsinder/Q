require 'globals'
require 'parser'
require 'dictionary'
require 'QCFunc'
require 'util'
require 'pl'

local ffi = require("ffi") 

-- ----------------
-- load( "CSV file to load", "meta data", "Global Metadata") 
-- Loads the CSV file and stores in the Q internal format
-- 
-- returns : table containing list of files for each column defined in metadata. 
--           If any error was encountered during load operation then negative status code  
-- ----------------

function load( csv_file, M , G)

  -- Check if the directory required by this load operation exists
  if( _G["Q_DATA_DIR"] == nil or not path.exists(_G["Q_DATA_DIR"]) or not path.isdir(_G["Q_DATA_DIR"]) )  then
      error("Please make sure that Q_DATA_DIR points to correct directory")
      return -1
  end
  
  if( _G["Q_META_DATA_DIR"] == nil or not path.exists(_G["Q_META_DATA_DIR"]) or not path.isdir(_G["Q_META_DATA_DIR"]) )  then
      error("Please make sure that Q_META_DATA_DIR points to correct directory")
      return -1
  end
 


  local fpTable = {}
  local fpNullTable = {} 
  local byteval = 0
  local retTable = {} 
  
  -- open file for each field defined in metdata
  for i, metadata in ipairs(M) do 
    -- If metadata name is not empty/null, then only create file and pointer for it
    if trim(metadata.name) ~= "" then
      local filePath = _G["Q_DATA_DIR"] .. "_" .. metadata.name
      fpTable[i] = create(filePath)
      retTable[i] = path.abspath(filePath)
      
      -- metadata NULL field is true then create null files and store null file ptr in table
      if metadata.null == "true" then -- To create nn file for storing null values
          local fpNullEntry = {}
          fpNullEntry[1] = create(_G["Q_DATA_DIR"] .. "_nn_" .. metadata.name)
          fpNullEntry[2] = byteval
          -- fpNullTable[i] = create(metadata.name.."_nn")
          fpNullTable[i] = fpNullEntry
  
      end 
      
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
                error("Dictionary does not exist. Aborting the operation") 
                return -1
            end 
          else
            local dict = _G["Q_DICTIONARIES"][dictName] 
            if(dict ~= nil) then 
                error("Dictionary with the same name exists, cannot create new dictionary")
            end
            
            -- create new dictionary, dictionary itself sets self reference in the globals
            local retVal = new_dictionary(dictName) 
          end
        
      end
     end
  end
  
  local row_count =0 ;
  local bitval = 8;

  -- TODO : Check if file:open makes more sense then io.lines 
  for line in io.lines(csv_file) do
    
    if(trim(line) == "") then 
       --skip empty lines in csv file, such scenario can be there if someone press enter after last line
    else
      local res= parse_csv_line(line,',')       -- call to parse to parse the line of csv file
      row_count = row_count + 1
      for i, metadata in ipairs(M) do 
          if trim(metadata.name) == "" then 
            -- Skip this line
          else
            local dataTypeShortCode = metadata["type"];
            local funName = g_qtypes[dataTypeShortCode]["txt_to_ctype"]
            local ctype = g_qtypes[dataTypeShortCode]["ctype"]
            local sizeOfData = g_qtypes[dataTypeShortCode]["width"]
            local dictionary = g_qtypes[dataTypeShortCode]["dictionary"]
                   
            local val = res[i]  
            
            -- NULL values handled here      
            if val == nil or trim(val) == "" then
               if(fpNullTable[i] == nil) then error("NUll value encountered in not null column .. column number " .. i ) end
              -- set the null bit
               if((row_count%bitval) <= bitval)then
                  byteval = setBit(i, fpNullTable[i][2], row_count)
                  fpNullTable[i][2]=byteval
               end
               -- set all null values to string 0, so that instead of some junk data 0 will be written to the file. 
               val = "0"
                
            else
              -- If value is not null then do dictionary string to number conversion
              if(dictionary ~= nil and dictionary == true) then 
                local dictName = metadata["dict"]
              -- local isDict = metadata["is_dict"] or false  
                local addNewValue = metadata["add"] or true 
                local dict = _G["Q_DICTIONARIES"][dictName]
                -- dictionary throws error if any during the add operation
                local retNumber = dict.add_with_condition(val, addNewValue)
                          
                -- now change the value to index instead of string
                val = tostring(retNumber)
                -- print("Value after conversion is " .. val)
              else 
                -- remove any spaces before or after string, otherwise number conversion function throws error
                val = trim(val) 
              end
            end
            -- print(val)
            local cVal = convertTextToCValue(funName, ctype, val, sizeOfData)
            write(fpTable[i],cVal, sizeOfData) 
            
            if(((row_count%bitval) ==0) and fpNullTable[i]~=nil)then
              writeNull(fpNullTable[i][1],fpNullTable[i][2], 1)
              fpNullTable[i][2]=0
            end      
          end
        end -- for loop ends
      end
  end
  
  
  
  -- close all the files
  for i, metadata in ipairs(M) do 
    -- If it was not null then only close the file
    if trim(metadata.name) ~= "" then
      --Flush the null pointer data 
      if((row_count%bitval) ~=0 and fpNullTable[i]~=nil)then
        writeNull(fpNullTable[i][1],fpNullTable[i][2], 1)
        fpNullTable[i][2]=0
      end
        
      -- close files
      if(fpNullTable[i] ~= nil) then
        close(fpNullTable[i][1])
      end
      close(fpTable[i])
    end
  end
  
  return retTable
end
