require 'pl'

function load_file_as_string(fname)
  local f = assert(io.open(fname))
  local str = f:read("*a")
  f:close()
  return str
end

-- Following code was taken from : http://lua-users.org/wiki/CsvUtils
-- Used to escape "'s , so that string can be inserted in csv line
function escape_csv (s)
  if string.find(s, '[,"]') then
    s = '"' .. string.gsub(s, '"', '""') .. '"'
  end
  return s
end


--[[ Following contains one liner example of useful tasks, which should be used directly 

- trim the string : stringx.strip(string_data)

- create lua table from string :  table =  pretty.read(table_in_string) 
- dump whole content of table for debugging : pretty.dump(table) 

- check file size : path.getsize(filepath) 

-- ]]
