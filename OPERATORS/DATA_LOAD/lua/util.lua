-- Following code was taken from : http://lua-users.org/wiki/CsvUtils

-- Used to escape "'s by toCSV
function escapeCSV (s)
  if string.find(s, '[,"]') then
    s = '"' .. string.gsub(s, '"', '""') .. '"'
  end
  return s
end


