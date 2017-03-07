require 'pl'

function valid_dir(dir_path)
    if dir_path == nil or not path.isdir(dir_path) then 
      return false 
    else 
      return true 
    end
end

function valid_file(file_path)
    if file_path == nil or not path.isfile(file_path)  then 
      return false 
    else 
      return true 
    end
end


-- Following code was taken from : http://lua-users.org/wiki/CsvUtils
-- Used to escape "'s , so that string can be inserted in csv line
function escape_csv (s)
  if string.find(s, '[,"]') then
    s = '"' .. string.gsub(s, '"', '""') .. '"'
  end
  return s
end


function preprocess_bool_values(metadata_table, ...)
  local col_names = {...}
  for i, metadata in pairs(metadata_table) do 
    for j, col_name in pairs(col_names) do
       if metadata[col_name] ~= nil and type(metadata[col_name]) ~= "boolean" then
        if string.lower(metadata[col_name]) == "true" then
          metadata[col_name] = true
        elseif string.lower(metadata[col_name]) == "false" then
          metadata[col_name] = false
        else
          error("Invalid value in metadata ".. i .. " for boolean field " .. col_name)
        end
       end
    end
  end
end


--[[ Following contains one liner example of useful tasks, which should be used directly 

- trim the string : stringx.strip(string_data)

- create lua table from string :  table =  pretty.read(table_in_string) 
- dump whole content of table for debugging : pretty.dump(table) 

- check file size : path.getsize(filepath) 

-- ]]