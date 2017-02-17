-- ------------------------------------------------------------------------------------
-- Creates closure for dictionary, so that dictionary can be treated as separate entity
-- ------------------------------------------------------------------------------------
require 'utils'
require 'parser'

-- --------------------------------------------------
-- New dictionary can be created by calling : 
-- local d1 = new_dictionary(dict_metadata)
-- Every new dictionary adds its reference to itself in the global variable called  _G["Q_DICTIONARIES"][dictName] . 
-- This can be used at the time shutdown time, to iterate over all dictionary and persist it to the disk. 
-- ----------------------------------------------
function Dictionary(dict_metadata)

  if(dict_metadata == nil or dict_metadata == "") then
    error("Dictionary metadata should not be empty")
  end  

  local dict_name = dict_metadata.dict
  local is_dict = dict_metadata.is_dict or false  -- default value is false, dictionary does not exist.. create one
  local add_new_value = dict_metadata.add or true  -- default value is true, add null values
  
  if(dict_name == nil or dict_name == "") then
    error("Please specify correct metadata")
  end
  
  if(is_dict == true) then
    local dict = _G["Q_DICTIONARIES"][dict_name] 
    if(dict == nil) then 
        error("Dictionary does not exist. Aborting the operation") 
    end 
  else
    local dict = _G["Q_DICTIONARIES"][dict_name] 
    if(dict ~= nil) then 
        error("Dictionary with the same name exists, cannot create new dictionary")
    end
  end
  
  
  -- Two tables are used here, so that bidirectional lookup becomes easy 
  -- and whole table scan is not required for one side
  local self = {
      text_to_number = {},
      number_to_text = {},  
      curr_index = 0,
  }
               
  -- private function, used to get next number, which should be assigned to new strings being added into dictionary               
  local get_next_number = function()
    self.curr_index = self.curr_index + 1
    return self.curr_index
  end
                        
  -- If the text exists in the dictionary
  local is_string_exists = function(text) 
      if self.text_to_number[text] ~= nil then
        return true 
      else 
        return false
      end
  end
  
  -- private function to add text into dictionary
  local put = function(text)
    -- if text does not exist then only add
    -- if(is_string_exists(text) ~= true) then 
      local random_value = get_next_number()
      self.text_to_number[text] = random_value
      self.number_to_text[random_value] = text
    -- end
  end
  
  -- Given a number, if that number exists in dictionary then the string corresponding to that number is returned, null otherwise
  local get_string_by_number = function(index)
    local num = self.number_to_text[index]
    return num
  end
          
  -- Given a string, if that string  exists in dictionary then the corresponding number to that string, null otherwise        
  local get_number_by_string = function(text) 
    return self.text_to_number[text]
  end
  
  -- --------------------------------------------------
  -- Adds the string into dictionary and returns number corresponding to the string 
  --     add_if_not_exists = true (default) :  If string exists in the dictionary then returns number corresponding to that string 
  --                                      otherwise adds the string into dictionary and returns the number at which string was added
  --     add_if_not_exists = false : If string exists in the dictionary then returns the number corresponding to that string 
  --                                        otherwise error out
  -- -------------------------------------------------
  local add_with_condition = function(text, add_if_not_exists)
  
    if(text == nil or text == "") then error("Cannot add nil or empty string in dictionary") end
  
    -- default to true for addIfExists condition
    if(add_if_not_exists == nil) then add_if_not_exists = true end
    
    
    local text_exists = is_string_exists(text)
    if(add_if_not_exists) then 
      if(text_exists) then 
        return get_number_by_string(text)
      else
        put(text)
        return get_number_by_string(text)
      end
    else
      if(text_exists) then 
        put(text)
        return get_number_by_string(text)
      else
        error("Text does not exist in dictionary")
      end
    end
    
  end
  
  
  
  -- ------------------------------------------------------------
  -- returns the number of entries currently stored in dictionary
  -- ------------------------------------------------------------
  local get_size = function()
    return #self.number_to_text
  end
  
  -- --------------------------------------
  -- save all dictionary content to the file specified by the filePath.   
  --     Currently only one table text_to_number is dumped into file as csv content. 
  --     CSV writing is the very basic function, which just escapes (‘ “ ) and writes the output. This function can be evolved if required
  -- -------------------------------------- 
  local save_to_file = function(file_path)
    file = io.open (file_path, "w")
    io.output(file);
    local separator = ",";
    
    for k,v in pairs(self.text_to_number) do 
      local s = escapeCSV(k) .. separator  .. v
      -- print("S is : " .. s)
      -- store the line in the file
       io.write(s, "\n")
    end    
    file:close() 
  end

  -- ----------------------------------------------
  -- reads the dictionary back from the file 
  --   It will read each line from the csv file and add entry in both table (text_to_number and number_to_text ) 
  -- -------------------------------------------
  
  local restore_from_file = function(file_path)
    for line in io.lines(file_path) do 
      local entry= parse_csv_line(line,',')
      -- each entry is the form string, number
      
      self.text_to_number[entry[1]] = tonumber(entry[2])
      self.number_to_text[tonumber(entry[2])] = entry[1]
    end  
  end
 
  
  local ret_function = {
      add_with_condition = add_with_condition,
      get_string_by_number = get_string_by_number , 
      get_number_by_string = get_number_by_string, 
      is_string_exists = is_string_exists, 
      get_size = get_size,
      save_to_file = save_to_file,
      restore_from_file = restore_from_file
  }              
  
  --put newly created dictionary into global variable
  _G["Q_DICTIONARIES"][dict_name] = ret_function
  return ret_function 
  
end

