-- env-setup and test for 'q_vagg' and sum() variants

local ffi = require("ffi") --Loading the FFI library 
local mylib = ffi.load("./adder.so") --set the path of your adder.so file here in ""
require 'q_vagg'

local mysum, status = vagg(mylib, {-127,100,5,-1}, "int8_t", "int16_t", "int8_sum") -- call to function in q_vagg.lua file 
print("\nTotal is " .. mysum);

local mysum, status = vagg(mylib, {3,2,5,-1}, "int16_t", "int32_t", "int16_sum")
print("\nTotal is " .. mysum);

local mysum, status = vagg(mylib, {-38457,2,5,-1}, "int32_t", "int64_t", "int32_sum")
print("\nTotal is " .. mysum);

local mysum, status = vagg(mylib, {-38788778,2,5,-1}, "int64_t", "int64_t", "int64_sum")
print("\nTotal is " .. mysum);

local mysum, status = vagg(mylib, {127,127,127}, "uint8_t", "uint16_t", "uint8_sum")
print("\nTotal is " .. mysum);

local mysum, status = vagg(mylib, {32767,32767}, "uint16_t", "uint32_t", "uint16_sum")
print("\nTotal is " .. mysum);

local mysum, status = vagg(mylib, {2147483647,2147483642,4}, "uint32_t", "uint64_t", "uint32_sum")
print("\nTotal is " .. mysum);

local mysum, status = vagg(mylib, {2147483647,2147483647}, "uint64_t", "uint64_t", "uint64_sum")
print("\nTotal is " .. mysum);

local mysum, status = vagg(mylib, {3.275412,2.275421,3.275412}, "float", "float", "float_sum")
print("\nTotal is " .. mysum);

local mysum, status = vagg(mylib, {3.27541212342,2.27541212342,3.27541212342}, "double", "double", "double_sum")
print("\nTotal is " .. mysum);

local mysum, status = vagg(mylib, {65,6,9}, "char", "char", "char_sum")
print("\nTotal is " .. mysum);

-- ---------------------------------------------------
print("------------DynCall tests------------------------")
-- assumes luadc.so is created; check README* under dyntest/.../luadc

require "package"
f,e = package.loadlib("../dyntest/bindings/lua/luadc/luadc.so", "luadc_open")
f()
local mylib = dc.load("./adder.so")
local mysum, status = vaggDynCall(mylib, {-127,100,5,-1}, "int8_t", "int16_t", "int8_sum") -- call to function in q_vagg.lua file 
print("\nTotal is " .. mysum);
