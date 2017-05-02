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

fns.testcase_results = function (v, filename, test_for, test_type, result)
  
  local date_time = os.date()
  -- absolute path 
  local abs_path = plpath.abspath(filename)
  -- split into dir path and filename
  local dir_path = plpath.splitpath(abs_path)
  -- find index of /Q/ or //Q//in dir path to get relative path from Q
  local req_path = string.find(dir_path, "[\\/]+Q[\\/]+")
  -- to print from index to end  
  req_path = string.sub(dir_path, req_path)
  --print(req_path)
  local test_status
  if result then test_status = "SUCCESS" else test_status = "FAILURE" end
  print(string.format("%10s ; %s ; %25s ; %10s ; %25s ; %15s ; %8s \n",
    "__Q_TEST__", date_time, req_path, test_for, v.name, test_type , test_status))
  -- print("__Q_TEST__"..date_time.." ; "..req_path.." ; LOAD_CSV ; "..v.name.." ; UNIT TEST ; SUCCESS \n")
end

return fns