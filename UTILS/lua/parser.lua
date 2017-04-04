-- --------------------------------------------------------------------------------------
-- This function was written using code example on url : http://lua-users.org/wiki/LuaCsv
-- -------------------------------------------------------------------------------------
require 'pl'

function parse_csv_line(line, sep) 
	res = {}
	local pos = 1
	sep = sep or ','
	while true do 
		local c = string.sub(line,pos,pos)
		if c == "" then
		  -- Insert the blank string for the last null field 
		  table.insert(res,"") break 
		end
		if c == '"' then
			-- quoted value (ignore separator within)
			local txt = ""
			repeat
				local startp,endp = string.find(line,'^%b""',pos)
				txt = txt..string.sub(line,startp+1,endp-1)
				pos = endp + 1
				c = string.sub(line,pos,pos) 
				if c == '"' then 
				  txt = txt..'"' 
				end 
				-- check first char AFTER quoted string, if it is another
				-- quoted string without separator, then append it
				-- this is the way to "escape" the quote char in a quote. example:
				--   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
			until (c ~= '"')
			table.insert(res,txt)
			assert(c == sep or c == "")
			if c == "" then 
			 break 
			end
			pos = pos + 1
		else	
			-- no quotes used, just look for the first separator
			local startp,endp = string.find(line,sep,pos)
			if startp then 
				table.insert(res,string.sub(line,pos,startp-1))
				pos = endp + 1  
			else
			 -- no separator found -> use rest of string and terminate
				table.insert(res,string.sub(line,pos))
				break
			end 
		end
	end
	return res
end
