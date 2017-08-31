local qconsts = require 'Q/UTILS/lua/q_consts'

-- test_type: need to specify the vector type to be created
-- assert_fns: function to be called to perform checks
-- name: testcase name
-- meta: meta data file for vector
-- num_elements: number of elements
-- qtype: need to specify qtype if you want to run test for specific qtype
-- gen_method: need to specify the generation method ('func', 'scalar', 'cmem_buf')


return {
  --=============================
  -- without nulls
  
  -- creating nascent vector, generating values by scalar
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "Creation of nascent vector_scalar", 
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 65540, 
    gen_method = "scalar", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8", "B1" }
  },
  
  -- creating nascent vector, generating values by cmem_buf
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "Creation of nascent vector_cmem_buf", 
    meta = "gm_create_nascent_vector6.lua",
    num_elements = 65540, 
    gen_method = "cmem_buf", 
    qtype = { "SC" }
  },
  
  -- creating nascent vector, generating values by scalar, put one element, check file size
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "Creation of nascent vector_scalar", 
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 1, 
    gen_method = "scalar", 
    qtype = { "B1" }
  },
  
  -- creating nascent vector, generating values by cmem_buf
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "Creation of nascent vector_cmem_buf", 
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 1025, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8", "B1" }
  },
  
  -- creating nascent vector, generating values by cmem_buf, put one element, check file size
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "Creation of nascent vector_cmem_buf", 
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 1, 
    gen_method = "cmem_buf", 
    qtype = { "B1" }
  },
  
  -- creating nascent vector, generating values by providing gen function,
  -- in case of gen function num_elements field is
  -- number of chunks (num_chunks) and not number of elements
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector2",
    name = "Creation of nascent vector_gen1_func", 
    meta = "gm_create_nascent_vector1.lua",
    num_elements = 2 , 
    gen_method = "func", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- nascent vector with is_memo false, eov and persist method should not work
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector3",
    name = "create_nascent_vector_memo_false",
    meta = "gm_create_nascent_vector3.lua",
    num_elements = 100,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },  
  
  -- nascent vector with is_read_only true
  -- try writing to read only vector
  -- for nascent vec, is_read_only is effective at vec:eov(true)
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector4",
    name = "write_to_nascent_vector_read_only",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 10,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },  
  
  -- nascent vector, try modifying memo after chunk is full, operation should fail
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector5",
    name = "update_memo_after_chunk_size",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = qconsts.chunk_size,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- creating materialized vectors 
  { 
    test_type = "materialized_vector", 
    name = "Creation of materialized vector", 
    assert_fns = "materialized_vector1",
    meta = "gm_create_materialized_vector1.lua",
    num_elements = 65540, 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  }, 
  
  -- materialized vector, set value at wrong index
  -- this testcase is failing as we can set value at wrong index without any error
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
  -- This testcase should segfault, how to catch it?
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
  
  --=============================
  -- with nulls
  
  -- creating nascent vector with nulls, generating values by scalar
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "create_nascent_vector_with_nulls_scalar", 
    meta = "gm_create_nascent_vector5.lua",
    num_elements = 65540, 
    gen_method = "scalar", 
    qtype = qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- creating nascent vector with nulls, generating values by cmem_buf
  {
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "create_nascent_vector_with_nulls_cmem_buf", 
    meta = "gm_create_nascent_vector5.lua",
    num_elements = 65540, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- nascent vector, vec._has_nulls is true but don't provide nn_data in put_chunk
  {
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector6",
    name = "nascent_vector_with_null_and_without_nn_data_in_put_chunk", 
    meta = "gm_create_nascent_vector5.lua",
    num_elements = 65, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- nascent vector, vec._has_nulls is true but don't provide nn_data in put1
  {
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector7",
    name = "nascent_vector_with_null_and_without_nn_data_in_put1", 
    meta = "gm_create_nascent_vector5.lua",
    num_elements = 65, 
    gen_method = "scalar", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- create materialized vector with has_nulls true
  { 
    test_type = "materialized_vector", 
    name = "create_materialized_vector_with_nulls", 
    assert_fns = "materialized_vector1",
    meta = "gm_create_materialized_vector4.lua",
    num_elements = 65540, 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- create materialized vector with has_nulls true but don't provide nn_file_name field
  -- This testcase is failing bcoz, 
  -- in vector code (lVector.lua) has_nulls is set/unset depending on existance of nn_file_name field
  { 
    test_type = "materialized_vector", 
    name = "materialized_vector_with_nulls_without_nn_file_name_field", 
    assert_fns = "materialized_vector5",
    meta = "gm_create_materialized_vector5.lua",
    num_elements = 65540, 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },

  -- create materialized vector with has_nulls true but provide wrong value of nn_file_name
  { 
    test_type = "materialized_vector", 
    name = "materialized_vector_with_nulls_with_wrong_nn_file_name", 
    assert_fns = "materialized_vector5",
    meta = "gm_create_materialized_vector6.lua",
    num_elements = 65540, 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- modify the materialized vector with has_nulls true without modifying respective nn vector
  -- this testcase is failing bcoz without modifying respcective nn_vec value, we can modify vec
  { 
    test_type = "materialized_vector", 
    name = "modify_materialized_vector_with_nulls_without_modifying_nn_vec", 
    assert_fns = "materialized_vector6",
    meta = "gm_create_materialized_vector4.lua",
    num_elements = 65540, 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },

}