package.path = package.path .. ";../lua/?.lua"
require("validate_meta")

_G["Q_META_DATA_DIR"] = "/tmp/" 
T = dofile("good_meta_data.lua")
for i, gm in ipairs(T) do
  print("Testing " .. gm)
  M = dofile(gm)
  status, err = pcall(validate_meta, M)
  if ( not status ) then 
    print("Error:", err)
  end
end
