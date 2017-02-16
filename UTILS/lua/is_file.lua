-- see if the file exists
function is_file(file)
   local f = io.open(file, "rb")
   if f then f:close() end
   return f ~= nil
end
