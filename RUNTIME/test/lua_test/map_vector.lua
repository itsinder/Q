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
    test_type = "nascent_vector",
    assert_fns = "nascent_vector1",
    name = "create_nascent_vector_cmem_buf", 
    meta = "gm_create_nascent_vector1.lua", 
    num_elements = 65540, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- nascent vector : generating values with scalar
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector1",
    name = "create_nascent_vector_scalar", 
    meta = "gm_create_nascent_vector1.lua", 
    num_elements = 1000, 
    gen_method = "scalar", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- nascent vector with is_memo false, try eov, this method should not work
  -- also you can not add element after eov
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector2_1",
    name = "nascent_vector_memo_false_check_add_element_after_eov",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 100,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- nascent vector with is_memo false, try persist, this method should not work
   {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector2_2",
    name = "nascent_vector_memo_false_check_persist",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 100,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- nascent vector with is_memo false, set is_memo explicitly to true then try vec:check(), 
  -- should be successful
  -- refer mail with subject "Testcase failing when setting memo explicitly with random boolean value"
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector2_3",
    name = "nascent_vector_memo_false_set_memo_and_vec_check",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 100,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },

  -- nascent vector with is_read_only true
  -- try writing to read only vector
  -- for nascent vec, is_read_only is effective at vec:eov(true)
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector3",
    name = "write_to_nascent_vector_read_only", 
    meta = "gm_create_nascent_vector3.lua", 
    num_elements = 10, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- try modifying memo after chunk is full, operation should fail
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector4",
    name = "update_memo_after_chunk_size", 
    meta = "gm_create_nascent_vector1.lua", 
    num_elements = qconsts.chunk_size, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- materialized vector
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector1",
    name = "create_materialized_vector", 
    meta = "gm_create_materialized_vector1.lua",
    num_elements = 65540,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },

  -- materialized vector, set value at wrong index
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector2",
    name = "materialized_vector_set_value_at_wrong_index", 
    meta = "gm_create_materialized_vector1.lua",
    num_elements = 65540,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },    

  -- materialized vector, try eov
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector3",
    name = "materialized_vector_eov", 
    meta = "gm_create_materialized_vector1.lua",
    num_elements = 65540,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },      
    
  -- read only materialized vector, try modifying value
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector4",
    name = "modify_read_only_materialized_vector", 
    meta = "gm_create_materialized_vector2.lua",
    num_elements = 65540,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },        
  
  -- create materialized vector where file is not present
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector5",
    name = "create_materialized_vector_file_not_present", 
    meta = "gm_create_materialized_vector3.lua",
    num_elements = 65540,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },  
  
  -- with nulls
  
  -- creating nascent vector with nulls, generating values by scalar
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "create_nascent_vector_with_nulls_scalar", 
    meta = "gm_create_nascent_vector4.lua",
    num_elements = 65540, 
    gen_method = "scalar", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- creating nascent vector with nulls, generating values by cmem_buf
  {
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "create_nascent_vector_with_nulls_cmem_buf", 
    meta = "gm_create_nascent_vector4.lua",
    num_elements = 65540, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
   -- nascent vector, vec._has_nulls is true but don't provide nn_data in put_chunk
  {
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector5",
    name = "nascent_vector_with_null_and_without_nn_data_in_put_chunk", 
    meta = "gm_create_nascent_vector4.lua",
    num_elements = 65, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  -- nascent vector, vec._has_nulls is true but don't provide nn_data in put1
  {
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector6",
    name = "nascent_vector_with_null_and_without_nn_data_in_put1", 
    meta = "gm_create_nascent_vector4.lua",
    num_elements = 65, 
    gen_method = "scalar", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
}