package.path = package.path .. ";../lua/?.lua"
require("load")

_G["Q_META_DATA_DIR"] = "/tmp/" 
T = dofile("good_data.lua")
for i, v in ipairs(T) do
  M = v.meta
  D = v.data
  status, err = pcall(load, D, M)
  if ( not status ) then 
    print("Error:", err)
  end
end
