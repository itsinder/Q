local ffi = require 'ffi'
local header_file = "core.h"
local qc = ffi.load('./lib_ab.so')
local JSON = require "JSON"


local file = io.open(header_file, "r")
ffi.cdef(file:read("*all"))
file:close()

ffi.cdef([[
void * malloc(size_t size);
void free(void *ptr);
]])

local function init_ab(config_file)
  local size = 20
  assert(config_file)
  local ab_struct = ffi.C.malloc(ffi.sizeof("AB_ARGS"))
  status = qc.init_ab(ab_struct, config_file, size)
  return ab_struct
end


local function sum_ab(ab_struct, json_body)
  local ab_tbl = assert(JSON:decode(json_body),
    "Not valid JSON")
  local sum = qc.sum_ab(ab_struct, ab_tbl['factor'])
  local result = {}
  result['sum'] = sum
  return JSON:encode(result)
end


local function print_ab(ab_struct)
  return qc.print_ab(ab_struct)
end


local function free_ab(ab_struct)
  return qc.free_ab(ab_struct)
end


ab_struct = init_ab("My_Config")
local ab_tbl = {}
ab_tbl['factor'] = 2
out_json = sum_ab(ab_struct, JSON:encode(ab_tbl))
out_tbl = JSON:decode(out_json)
for i, v in pairs(out_tbl) do
  print(i, v)
end
print_ab(ab_struct)
free_ab(ab_struct)
