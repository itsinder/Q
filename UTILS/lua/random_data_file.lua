-- Unique random filename is returned
local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end


local function random_string(length_inp)
   local length = length_inp or 11
   --return string.rep("_hey", length)
   return tostring("_" .. math.random(11111111,99999999) .. ".bin")
   -- local result = {}
   -- for loop = 1,length do
   --    result[loop] = charset[math.random(1, #charset)]
   -- end
   -- return table.concat(result)
end

return function(length)
   local name = nil
   while (name == nil)
      do
         name = string.format(  "%s/_%s" ,require("Q/q_export").Q_DATA_DIR, random_string(length))
         -- return name
         --print ("DATA FILE GEN " .. Q.Q_DATA_DIR)
         local f=io.open(name,"r")
         if f ~=nil then
            io.close(f)
            name = nil
         else
            return name
         end
      end
      return name
   end


