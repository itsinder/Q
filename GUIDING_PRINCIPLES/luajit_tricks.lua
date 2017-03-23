1. Converting number to C's float/int/double and back

Consider two functions with prototypes int f_one(int x); and float f_two(float x); In luajit there exists only 1 type, number which should work with both of them. Therefore when making calls to either of these two prototypes the "number" is mapped to a double, which is then coerced to the type int and float respectively. Also note that the return value is converted back to the number type natively.

2. Adding lua numbers to different types C buffers (in binary format)
The simplest remedy, is to use point 1 and have a function that takes an array and writes out the correct type value at the correct index, but things can be easier than that.

Luajit supports array indexing and values can be set at certain offsets. When a value is set using this convention, the value is coerced to the appropriate "C value" and saved in binary at that location. 

3. Casting types
Luajit allows us to cast memory as any data type it knows about (including structs). This allows us to have a single buffer (instead of 1 or each type) into which data can be written and decoded appropriately.


Conversion rules: http://luajit.org/ext_ffi_semantics.html (Conversions from Lua
objects to C types) 
