os.execute("rm -f _*.bin")
local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ; 
local buf = cmem.new(4096)
-- for k, v in pairs(vec) do print(k, v) end 

-- create a nascent vector
y = Vector.new('B1')
local num_elements = 100000
for j = 1, num_elements do 
  local bval = nil
  if ( ( j % 2 ) == 0 ) then bval = true else bval = false end
  local s1 = Scalar.new(bval, "B1")
  y:append(s1)
end
print("writing meta data of nascent vector")
M = loadstring(y:meta())(); for k, v in pairs(M) do print(k, v) end
y:eov()
print("writing meta data of persisted vector")
M = loadstring(y:meta())(); for k, v in pairs(M) do print(k, v) end
y:persist()
--=========================
print("Completed ", arg[0])
os.exit()
