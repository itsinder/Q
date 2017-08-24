-- test_type: need to specify the vector type to be created
-- name: testcase name
-- meta: meta data file for vector
-- num_elements: number of elements
-- qtype: need to specify qtype and not in meta data file

-- gen_method: need to specify the generation method
-- like scalar, gen function or randomly in the iteration
local qconsts = require 'Q/UTILS/lua/q_consts'

return { 
  -- creating nascent vectors
  -- without nulls
  
  -- nascent vector : generating values with cmem_buf
  {
    test_type = "nascent_vector1",
    name = "create_nascent_vector_cmem_buf", 
    meta = "gm_create_nascent_vector1.lua", 
    num_elements = 65540, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- nascent vector : generating values with scalar
  {
    test_type = "nascent_vector1",
    name = "create_nascent_vector_scalar", 
    meta = "gm_create_nascent_vector1.lua", 
    num_elements = 1000, 
    gen_method = "scalar", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- nascent vector with is_memo false
  {
    test_type = "nascent_vector2",
    name = "create_nascent_vector_memo_false", 
    meta = "gm_create_nascent_vector2.lua", 
    num_elements = 10, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },

  -- nascent vector with is_read_only true
  -- try writing to read only vector
  -- for nascent vec, is_read_only is effective at vec:eov(true)
  {
    test_type = "nascent_vector3",
    name = "write_to_nascent_vector_read_only", 
    meta = "gm_create_nascent_vector3.lua", 
    num_elements = 10, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- try modifying memo after chunk is full, operation should fail
  {
    test_type = "nascent_vector4",
    name = "update_memo_after_chunk_size", 
    meta = "gm_create_nascent_vector1.lua", 
    num_elements = qconsts.chunk_size, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- materialized vector
  {
    test_type = "materialized_vector",
    name = "create_materialized_vector", 
    meta = "gm_create_materialized_vector.lua",
    num_elements = 65540,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },  
  
}
