package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"

local Vector = require 'Vector'
require 'globals'

local v1 = Vector{field_type='I4', field_size = 4,chunk_size = 5,
  filename="o.txt",
}

print (v1:length())

--print (v1:size()) 
--working method after renaming vector length function to size