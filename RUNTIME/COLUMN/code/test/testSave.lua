local save = require "save"
local ffi = require "ffi"
local q_core = require "q_core"
local Vector = require 'Vector'
local Column = require "Column"
g_valid_types = {}
g_valid_types['i'] = 'int'
g_valid_types['f'] = 'float'
g_valid_types['d'] = 'double'
g_valid_types['c'] = 'char'
g_valid_types['B1'] = 'unsigned char'
g_chunk_size = 16
--local size = 1000
--create bin file of only ones of type int
local v1 = Vector{field_type='i',
filename='test1.txt', }
save("vone",v1)
-- Not a good idea as strings will be quoted when saved and we will have to
-- deserialize them
save("vtwo", tostring(v1))
local c3 = Column{field_type='i',
filename='test1.txt', }
save("cthree", tostring(c3))
local c4 = Column{field_type='i',
filename='test1.txt', nn=true}
save("cfour", tostring(c4))

