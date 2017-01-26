require 'parser'
require 'QCFunc'
require 'globals'

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

  --[[
    Flow should be like this 
    - Parse the line and get array of cell values
    - Now for each cell 
      - Convert the value into appropriate type by calling the C function 
          - While calling the c function use malloc to allocate appropriate number of bytes
          - C function will return value in this pointer 
      - Call another c function to store the data into file
  --]]
  local fpTable = {}
  
  for i, metadata in ipairs(M) do 
    -- TODO : Handle case where metadata name is empty
    fpTable[i] = create(metadata.name)
  end
  
    -- TODO : Check if file:open makes more sense then io.lines 
  for line in io.lines(csv_file) do
    local res= ParseCSVLine(line,',')       -- call to parse to parse the line of csv file
    
    
    
    for i, metadata in ipairs(M) do 
      if metadata.name == "" then 
        -- Skip this line
      else
        --[[
        take the value 
        call the c function 
        get the value back 
        
        -- ]]
        local val = res[i]  
      
        
        local dataTypeShortCode = metadata["type"];
        local funName = g_qtypes[dataTypeShortCode]["txt_to_ctype"]
        local sizeOfData = g_qtypes[dataTypeShortCode]["width"]
        
        cVal = convertTextToCValue(funName, val, sizeOfData)
        write(fpTable[i],cVal, sizeOfData) 
        
      end
    end
  end
  
  for i, metadata in ipairs(M) do 
      close(fpTable[i])
  end

 
  

end

-- -----------------------------------------
-- converts given lua string value to c value
-- ------------------------------------------
function convertToCValue(val)
  
end

function printTable(tt)
  for k,v in pairs(tt) do 
    if(type(k)== "table") then 
      printTalbe(k)
    else
      print(k) 
    end
    
    if(type(v) == "table") then 
      printTable(v)
    else
      print(v)
    end
    
  end
end

