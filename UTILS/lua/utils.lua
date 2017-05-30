local plpath = require 'pl.path'
local fns = {}

fns.load_file_as_string = function (fname)
  local f = assert(io.open(fname))
  local str = f:read("*a")
  f:close()
  return str
end
-- Following code was taken from : http://lua-users.org/wiki/CsvUtils
-- Used to escape "'s , so that string can be inserted in csv line
fns.escape_csv = function (s)
  if string.find(s, '[,"]') then
    s = '"' .. string.gsub(s, '"', '""') .. '"'
  end
  return s
end

fns.preprocess_bool_values = function (metadata_table, ...)
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

fns.testcase_results = function (v, test_for, test_type, result, spare)
  
  local date = os.date("%d/%m/%Y")
  local time = os.date("%H:%M")
  
  local dir_path = plpath.currentdir()
  dir_path = dir_path.."/"
  -- find start and end index of /Q/ or //Q//in dir path to get relative path from Q
  local start_index, end_index 
  start_index, end_index = string.find(dir_path, "[\\/]+Q[\\/]+")
  -- remove /Q/ or //Q//  
  local req_path = string.sub(dir_path, end_index)
  -- search if one more /Q/ or //Q// folder exists and remove it
  start_index, end_index = string.find(req_path, "[\\/]+Q[\\/]+")
  if end_index~=nil then req_path = string.sub(req_path, end_index+1) else req_path = string.sub(req_path, 2) end
  
  -- test case status is derived from result paramater 
  -- whether it is true or false
  local test_status
  if result then test_status = "SUCCESS" else test_status = "FAILURE" end
  
  print(string.format("%s%s %s ; %s ; %s ; %s ; %s ; %s ; %s \n",
    "__Q_TEST__", date, time, req_path, test_for, v.name, test_type , spare, test_status))
  -- print("__Q_TEST__"..date_time.." ; "..req_path.." ; LOAD_CSV ; "..v.name.." ; UNIT TEST ; SUCCESS \n")
end

return fns