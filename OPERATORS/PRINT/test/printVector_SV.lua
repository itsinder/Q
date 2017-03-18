package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
package.path = package.path .. ";../lua/?.lua"
--package.cpath = ";../../../Q2/code/?.so"


local Vector = require 'Vector'
require 'globals'
require 'print_csv'
local Dictionary = require "dictionary"

_G["Q_DICTIONARIES"] = {}
local dictionary = Dictionary({dict = "D1", is_dict = false, add=true})
dictionary:add_with_condition("e1")
dictionary:add_with_condition("e2")
dictionary:add_with_condition("e3")
dictionary:add_with_condition("e4")
dictionary:add_with_condition("e5")
dictionary:add_with_condition("e6")

print(dictionary:get_string_by_index(1))
print(dictionary:get_string_by_index(2))
print(dictionary:get_string_by_index(3))
print(dictionary:get_string_by_index(4))
print(dictionary:get_string_by_index(5))
print(dictionary:get_string_by_index(6))

local v1 = Vector{field_type='SV', field_size = 4,chunk_size = 5,
  filename="./bin/SV_1.bin",
}
--local dict = Dict.new(name)...._G

local v2 = Vector{field_type='SV', field_size = 4,chunk_size = 6,
  filename="./bin/SV_2.bin",
}
v1:set_meta("dir", "D1")
v2:set_meta("dir", "D1")

print(_G["Q_DICTIONARIES"][v2:get_meta("dir")]:get_string_by_index(1))

initialize_filter()

arr = {v2,v1,4}
print_csv(arr,nil,"csv_file.txt")
