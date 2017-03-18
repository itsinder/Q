package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
package.path = package.path .. ";../lua/?.lua"

local Vector = require 'Vector'
require 'globals'
require 'print_csv'

local v1 = Vector{field_type='I2', field_size = 2,chunk_size = 5,
  filename="./bin/I2_1.bin",
}

local v2 = Vector{field_type='I2', field_size = 2,chunk_size = 6,
  filename="./bin/I2_2.bin",
}
initialize_filter()
arr = {v2,v1,4}
print_csv(arr,nil,"csv_file.txt")
