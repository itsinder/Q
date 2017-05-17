local save = require "save"
local ffi = require "ffi"
local q_core = require "q_core"
local Vector = require 'Vector'
local Column = require "Column"
local dictionary = require "Dictionary"
g_valid_types = {}
g_valid_types['i'] = 'int'
g_valid_types['f'] = 'float'
g_valid_types['d'] = 'double'
g_valid_types['c'] = 'char'
g_valid_types['B1'] = 'unsigned char'
g_chunk_size = 16
--local size = 1000
--create bin file of only ones of type int
v1 = Vector{field_type='i',
filename='test1.txt', }
-- Not a good idea as strings will be quoted when saved and we will have to
-- deserialize them
c3 = Column{field_type='i',
filename='test1.txt', }
c4 = Column{field_type='i',
filename='test1.txt', nn=true}
c4:set_meta("hey", 4)
c4:set_meta("bye", {1,2,3})
my_dict = dictionary("hello")
my_dict:add("please")
save("_try.txt")
for line in io.lines(os.getenv("Q_METADATA_DIR") .. "/_try.txt") do
   print(line)
end

