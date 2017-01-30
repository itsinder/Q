-- Following code was taken from : http://lua-users.org/wiki/CsvUtils

-- Used to escape "'s by toCSV
function escapeCSV (s)
  if string.find(s, '[,"]') then
    s = '"' .. string.gsub(s, '"', '""') .. '"'
  end
  return s
end


-- Trip string : taken from : http://lua-users.org/wiki/CommonFunctions
function trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end


