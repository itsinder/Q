-- env-setup and test for 'q_vagg' and sum() variants

local ffi = require("ffi") --Loading the FFI library 
local mylib = ffi.load("./adder.so") --set the path of your adder.so file here in ""
require 'q_vagg'
local sum

print("Program Started")

local mysum, status = vagg(mylib, {-127,100,5,-1}, "int8_t", "int16_t", "int8_sum") -- call to function in q_vagg.lua file 
--print("\nTotal is " .. mysum);
sum=-127+100+5-1
if mysum~=sum  then 
	print("FAILURE") 
end 

local mysum, status = vagg(mylib, {3,2,5,-1}, "int16_t", "int32_t", "int16_sum")
--print("\nTotal is " .. mysum);
sum=3+2+5-1
if mysum~=sum  then 
	print("FAILURE") 
end


local mysum, status = vagg(mylib, {-38457,2,5,-1}, "int32_t", "int64_t", "int32_sum")
--print("\nTotal is " .. mysum);
sum=-38457+2+5-1
if mysum~=sum  then 
	print("FAILURE") 
end



local mysum, status = vagg(mylib, {-38788778,2,5,-1}, "int64_t", "int64_t", "int64_sum")
--print("\nTotal is " .. mysum);
sum=-38788778+2+5-1
if mysum~=sum  then 
	print("FAILURE") 
end



local mysum, status = vagg(mylib, {127,127,127}, "uint8_t", "uint16_t", "uint8_sum")
--print("\nTotal is " .. mysum);
sum=127+127+127
if mysum~=sum  then 
	print("FAILURE") 
end

local mysum, status = vagg(mylib, {32767,32767}, "uint16_t", "uint32_t", "uint16_sum")
--print("\nTotal is " .. mysum);
sum=32767+32767
if mysum~=sum  then 
	print("FAILURE") 
end

local mysum, status = vagg(mylib, {2147483647,2147483642,4}, "uint32_t", "uint64_t", "uint32_sum")
--print("\nTotal is " .. mysum);
sum=2147483647+2147483642+4
if mysum~=sum  then 
	print("FAILURE") 
end

local mysum, status = vagg(mylib, {2147483647,2147483647}, "uint64_t", "uint64_t", "uint64_sum")
--print("\nTotal is " .. mysum);
sum=2147483647+2147483647
if mysum~=sum  then 
	print("FAILURE") 
end


local mysum, status = vagg(mylib, {1099511627776,1099511627776}, "uint64_t", "uint64_t", "uint64_sum")
-- print("\nTotal is " .. mysum);
sum=1099511627776+1099511627776
-- print("Sum is " .. sum)
if mysum~=sum  then
        print("FAILURE")
end


local mysum, status = vagg(mylib, {18446744073709551616,1}, "uint64_t", "uint64_t", "uint64_sum")
-- print("\nTotal is " .. mysum);
sum=18446744073709551616+1
-- print("Sum is " .. sum)
if mysum~=sum  then
        print("FAILURE {18446744073709551616,1}; expected = " .. sum .. "; actual = " .. mysum)
end

local mysum, status = vagg(mylib, {3.275412,2.275421,3.275412}, "float", "float", "float_sum")
--print("\nTotal is " .. mysum);
sum=3.275412+2.275421+3.275412
mysum=mysum*1000000
mysum=math.ceil(mysum)
mysum=mysum/1000000
if mysum~=sum  then 
	print("FAILURE") 
end

local mysum, status = vagg(mylib, {3.27541212342,2.27541212342,3.27541212342}, "double", "double", "double_sum")
--print("\nTotal is " .. mysum);
sum=3.27541212342+2.27541212342+3.27541212342
mysum=mysum*1000000
mysum=math.ceil(mysum)
mysum=mysum/1000000

sum=sum*1000000
sum=math.ceil(sum)
sum=sum/1000000
if mysum~=sum  then 
	print("FAILURE see",mysum,sum) 
end

local mysum, status = vagg(mylib, {65,6,9}, "char", "char", "char_sum")
--print("\nTotal is " .. mysum);
sum=65+6+9
if mysum~=sum  then 
	print("FAILURE see",sum) 
end

-- ---------------------------------------------------
print("------------DynCall tests------------------------")
-- assumes luadc.so is created; check README* under dyntest/.../luadc

require "package"
f,e = package.loadlib("../dyntest/bindings/lua/luadc/luadc.so", "luadc_open")
f()
local mylib = dc.load("./adder.so")
local mysum, status = vaggDynCall(mylib, {-127,100,5,-1}, "int8_t", "int16_t", "int8_sum") -- call to function in q_vagg.lua file 
sum=-127+100+5-1
if mysum~=sum  then 
	print("FAILURE") 
end 

print("Exiting test suite.")