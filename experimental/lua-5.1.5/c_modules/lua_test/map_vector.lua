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
  
  -- generating values with cmem_buf
  {
    testcase_no = 1,
    test_type = "nascent_vector1",
    name = "create_nascent_vector1", 
    meta = "gm_create_nascent_vector1.lua", 
    num_elements = 1000, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" } 
  },
  
  -- generating values with scalar
  {
    testcase_no = 2,
    test_type = "nascent_vector1",
    name = "create_nascent_vector1", 
    meta = "gm_create_nascent_vector1.lua", 
    num_elements = 1000, 
    gen_method = "scalar", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" } 
  }
}
