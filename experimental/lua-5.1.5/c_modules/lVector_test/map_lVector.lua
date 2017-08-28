-- test_type: need to specify the vector type to be created
-- name: testcase name
-- meta: meta data file for vector
-- num_elements: number of elements
-- qtype: need to specify qtype and not in meta data file

-- gen_method: need to specify the generation method
-- like scalar, gen function or randomly in the iteration

return { 
  -- creating nascent vectors
  -- without nulls

  -- generating values by providing gen function
  -- in case of gen function num_elements field is
  -- number of chunks (num_chunks) and not number of elements
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector2",
    name = "Creation of nascent vector_gen1_func", 
    meta = "gm_create_nascent_vector1.lua",
    num_elements = 2 , 
    gen_method = "func", 
    qtype = { "I1", "I2", "I4", "F4" } 
  },
  
  -- generating values by scalar
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "Creation of nascent vector_scalar", 
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 10, 
    gen_method = "scalar", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8"  }   
  },

  -- generating values by itr
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "Creation of nascent vector_cmem_buf", 
    meta = "gm_create_nascent_vector3.lua",
    num_elements = 10, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }  
  },
  
  
  -- creating materialized vectors 
  -- without nulls 
  { 
    test_type = "materialized_vector", 
    name = "Creation of materialized vector", 
    assert_fns = "materialized_vector1",
    meta = "gm_create_materialize_vector.lua",
    num_elements = 10, 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" } 
  }, 
}