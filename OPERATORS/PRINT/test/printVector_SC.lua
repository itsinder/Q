package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
package.path = package.path .. ";../lua/?.lua"
--package.cpath = ";../../../Q2/code/?.so"


local Vector = require 'Vector'
require 'globals'
require 'print_csv'
local field_size = 8

local v1 = Vector{field_type='SC', field_size = field_size,chunk_size = 5,
filename="./bin/SC_1.bin",   
}

local v2 = Vector{field_type='SC', field_size = field_size,chunk_size = 6,
filename="./bin/SC_2.bin", 
}
initialize_filter()
arr = {v2,v1,4}
print_csv(arr,nil,"csv_file.txt")
