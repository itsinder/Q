package.path = package.path .. ";../../../Q2/code/?.lua"

local Vector = require 'Vector'
require 'globals'
require 'parser'
require 'dictionary'
require 'q_c_functions'
require 'pl'

local ffi = require("ffi") 

-- ----------------
-- load( "CSV file to load", "meta data", "Global Metadata") 
-- Loads the CSV file and stores in the Q internal format
-- 
-- returns : table containing list of files for each column defined in metadata. 
--           If any error was encountered during load operation then negative status code  
-- ----------------


-- validate meta-data & create vector + null vector for each of the file being created 
local vectors = {}
local nil_vectors = {}
local col_count = 0 --each field in the metadata represents one column in csv file
local col_idx = 0
local row_idx = 0
local col_num_nil = {}  
local validate_input, valid_file, valid_dir, initialize, cleanup
local NULL  
local NOT_NULL
local chunk_size = 1

function load( csv_file_path, metadata , G)
  
  validate_input(csv_file_path, metadata, G)   
  col_count = #metadata
  
  initialize(metadata)  
  
  
  for line in io.lines(csv_file_path) do
 
    -- local col_values= parse_csv_line(line,',')       -- call to parse to parse the line of csv file
    local status, col_values = pcall(parse_csv_line, line, ',' )
    if(status == false ) then error("Invalid CSV data") end
    
    if(#col_values ~= col_count) then 
     -- If its the single column and nil is allowed then its a valid case
     if(col_count == 1) then
       if(nil_vectors[col_count] == nil) then error("Null value found in not null field") end 
     else
      error("Column count does not match with count of column in metadata")
     end 
    end
    
    for col_idx = 1, col_count do
    
      local data_type_short_code = metadata[col_idx]["type"];
      local txt_to_ctype_func_name = g_qtypes[data_type_short_code]["txt_to_ctype"]
      local ctype = g_qtypes[data_type_short_code]["ctype"]
      local size_of_data = g_qtypes[data_type_short_code]["width"]
      
      -- For varchar, do the dictionary conversion
      local dictionary =  data_type_short_code == "varchar" or false
      
      local current_value = col_values[col_idx]          
      if current_value == nil or stringx.strip(current_value) == "" then 
        -- nil values
        if(nil_vectors[col_idx] == nil) then error("Null value found in not null field .. column number " .. col_idx ) end
        -- TODO check putvalue syntaxt
        nil_vectors[col_idx]:put_chunk(NULL, chunk_size)
        if col_num_nil[col_idx] == nil then 
          col_num_nil[col_idx] =  1 
        else 
          col_num_nil[col_idx] = col_num_nil[col_idx] + 1
        end 
        current_value = "0" -- setting here 0, so that instead of some garbage 0 will be written in file
     
      else
        -- Not nil value
        
        if(nil_vectors[col_idx] ~= nil) then
          nil_vectors[col_idx]:put_chunk(NOT_NULL, chunk_size) 
        end
        -- If value is not null then do dictionary string to number conversion
        if(dictionary ~= nil and dictionary == true) then 
          local dict_name = metadata[col_idx].dict
          local add_new_value = metadata[col_idx].add or true 
          local dict = _G["Q_DICTIONARIES"][dict_name]
          -- dictionary throws error if any during the add operation
          local ret_number = dict.add_with_condition(current_value,add_new_value)                    
          -- return is number, convert it to string
          current_value = tostring(ret_number)

        else 
          -- remove any spaces before or after string, otherwise number conversion function throws error
          current_value = stringx.strip(current_value) 
        end
      end
      
      if(data_type_short_code == "SC") then
        -- For Fixed length string width of the data comes from the metadata instead of globals  
        local size_of_data = metadata[col_idx]["size"];
        -- For SC add the size_of_data to the multiplication
        local c_value = convert_text_to_c_value(txt_to_ctype_func_name, ctype, current_value, size_of_data)
        vectors[col_idx]:put_chunk(c_value, chunk_size*size_of_data)        
      else
        local c_value = convert_text_to_c_value(txt_to_ctype_func_name, ctype, current_value, size_of_data)
        vectors[col_idx]:put_chunk(c_value, chunk_size) 
      end
    end  
    row_idx = row_idx + 1
  end
  
  --cleanup
  cleanup(metadata)  
  -- close all vectors & delete the null vector if it is not required..
  return vectors
end

initialize = function(metadata)

  -- initialize value which needs to be written to null vector, since it will be either 0 or 1
  NULL =  convert_text_to_c_value("txt_to_I1", "int8_t", "1", 1)
  NOT_NULL =  convert_text_to_c_value("txt_to_I1","int8_t", "0", 1)

  for i = 1, col_count do 
    -- If metadata name is not empty/null, then only create new vector
    if stringx.strip(metadata[i].name) ~= "" then
      vectors[i] = Vector{field_type=metadata[i].type, filename= _G["Q_DATA_DIR"] .. "_" ..metadata[i].name, write_vector=true}
      if metadata[i].null == true then
        nil_vectors[i] =  Vector{field_type="int8_t", filename= _G["Q_DATA_DIR"] .. "_nn_" ..metadata[i].name, write_vector=true}
      end
      
      if(metadata[i].type == "varchar") then
        --TODO: add dictionary field handling in dictionary code itself
        Dictionary(metadata[i]) 
      end 
    end    
  end
end

cleanup = function(metadata)
  for i = 1, col_count do 
    -- If metadata name is not empty/null, then only create new vector
    if stringx.strip(metadata[i].name) ~= "" then
      vectors[i]:eov()
      --TODO : Deleting the null vector if its not required
      if metadata[i].null == true then
        nil_vectors[i]:eov()
      end 
    end     
  end
end


validate_input =  function(csv_file_path, metadata, G)
  if( metadata == nil ) then error("Metadata should not be nil") end
  if( type(metadata) ~= "table") then error("Please specify correct metadata") end
  if( not valid_file(csv_file_path) )  then  error("Please make sure that csv_file_path is correct") end
  -- Check if the directory required by this load operation exists
  if( not valid_dir(_G["Q_DATA_DIR"]) )  then  error("Please make sure that Q_DATA_DIR points to correct directory") end
  if( not valid_dir(_G["Q_META_DATA_DIR"]) )  then  error("Please make sure that Q_META_DATA_DIR points to correct directory") end
  
  -- now look at fields of metadata
  for i,m in pairs(metadata) do
     if m.name == nil or m.type == nil or g_qtypes[m.type] == nil  then
        error("Please specify correct metadata") 
     end
  end
  
  -- file should not be empty
  local file_size  =  path.getsize(csv_file_path)
  if file_size == 0 then error("File should not be empty") end
   
end

valid_dir = function(dir_path)
    if( dir_path == nil or not path.exists(dir_path) or not path.isdir(dir_path) ) then 
      return false 
    else 
      return true 
    end
end

valid_file = function(file_path)
    if( file_path == nil or not path.exists(file_path) or not path.isfile(file_path) ) then 
      return false 
    else 
      return true 
    end
end


