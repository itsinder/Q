require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'
local Vector = require 'libvec' 
local Scalar = require 'libsclr' 
local ffi = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
-- TODO delete below
ffi.cdef([[
typedef struct _cmem_rec_type {
  void *data;
  int64_t size;
  char field_type[4]; // MAX_LEN_FIELD_TYPE TODO Fix hard coding
  char cell_name[16]; // 15 chaarcters + 1 for nullc, mainly for debugging
} CMEM_REC_TYPE;
]]
)

local tests = {} 

tests.t1 = function()
  local qtypes = { "I4", "I8",  "F8" }
  local num_elements = 64*64*1024
  local iter = 1
  local buf = ffi.malloc(16)
  for _, qtype in ipairs(qtypes) do   
    local ctype = assert(qconsts.qtypes[qtype].ctype)
    for i=1, iter do
      print("QType/Iteration: ", qtype, i)
      local y = Vector.new(qtype)
      --==== Set some initial values 
      for j = 1, num_elements do
        local s = assert(Scalar.new(j*10, qtype))
        local status = y:put1(s)
        assert(status, "j = " .. j)
      end
      assert(y:eov())
      --==== Now modify the values to something else
      assert(y:start_write())
      for j = 1, num_elements do
        assert(y:set(j*9, j-1, 1))
      end
      assert(y:end_write())
  
      for j= 1, y:num_elements() do
        local ret_cmem, ret_len, ret_val  = y:get(j-1, 1)
        local w = ffi.cast("CMEM_REC_TYPE *", ret_cmem)
        local z = ffi.cast(ctype .. " *", w[0].data)
        assert(z[0] == j*9)
      end
  
    -- Explicit call to garbage collection
    --print("Calling Garbage Collector")
    --collectgarbage()
    end
  end
  print("Successfully completed test t1")
end
--==========================================

return tests
