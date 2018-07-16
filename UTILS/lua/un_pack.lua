local T = {}

-- Q.un_pack(x) : gives table of scalars
            -- Return value:
              -- table of scalar values

-- Convention: Q.un_pack(vector)
-- 1) vector : a vector

local function un_pack(x)
  assert(x and type(x) == "lVector", "input must be of type lVector")
  -- Check the vector for eval(), if not then call eval()
  local tbl_of_sclr = {} 
  if not x:is_eov() then
    x:eval()
  end
    
  for i = 0, x:length()-1 do
    local value = x:get_one(i)
    tbl_of_sclr[#tbl_of_sclr + 1] = value
  end
  
  return tbl_of_sclr
end

T.un_pack = un_pack
require('Q/q_export').export('un_pack', un_pack)

return T
