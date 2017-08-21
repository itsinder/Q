-- TODO: check function is yet to be implemented
return { 
  -- creating nascent vector
  -- genarating values by providing gen1 function
  {  testcase_no = 1, test_type="nascent_vector", name = "Creation of nascent vector1", meta = "gm_create_nascent_vector1.lua",
    num_elements = 1024 , gen_method = "func", check_function= "" },
  -- creating nascent vector
  -- genarating values by scalar
  {  testcase_no = 2, test_type="nascent_vector", name = "Creation of nascent vector2", meta = "gm_create_nascent_vector2.lua",
    num_elements = 100, gen_method = "scalar", check_function= "" },
  -- creating nascent vector
  -- genarating values by itr
  {  testcase_no = 3, test_type="nascent_vector", name = "Creation of nascent vector2", meta = "gm_create_nascent_vector3.lua",
    num_elements = 1024, gen_method = "itr", check_function= "" },
   
}
