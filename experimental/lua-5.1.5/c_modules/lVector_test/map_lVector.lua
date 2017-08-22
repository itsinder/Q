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

  -- generating values by providing gen1 function
  { test_type = "nascent_vector", name = "Creation of nascent vecto_func", meta = "gm_create_nascent_vector1.lua",
    num_elements = 10 , gen_method = "func", qtype = { "I1", "I2", "I4", "F4" } },

  -- generating values by scalar
  {  test_type = "nascent_vector", name = "Creation of nascent vector_scalar", meta = "gm_create_nascent_vector2.lua",
    num_elements = 10, gen_method = "scalar", qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }   },

  -- generating values by itr
  { test_type = "nascent_vector", name = "Creation of nascent vector_itr", meta = "gm_create_nascent_vector3.lua",
    num_elements = 10, gen_method = "itr", qtype = { "I4" }  },
  
  
  -- creating materialized vectors 
  -- without nulls 
 
  {  test_type = "materialized_vector", name = "Creation of materialized vector", meta = "gm_create_materialize_vector.lua",
     num_elements = 10, qtype = { "I1", "I2", "I4", "I8" } }, 
  
}
