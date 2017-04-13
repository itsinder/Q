require("validate_meta")
require("error_code")

local T = dofile("meta_data.lua")

for i, gm in ipairs(T) do
  print("Testing " .. gm)
  M = dofile("test_metadata/"..gm)
  status, err = pcall(validate_meta, M)
  
  if ( not status ) then 
    print("Error:", err)
  end
  
end