return {
  
  -- checks the name of the binary file created by calling eov function in vector class
  { name = "valid I1", field_type = 'I1', filename="I1.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = { -128, 0, 127, 11, 5, 6, 7, 8 } 
  },
    -- write vector field not present
  { name = "nil write vector", field_type = 'I1', filename="I1.bin", chunk_size = 8, category = "category1",
    input_values = { -128, 0, 127, 11, 5, 6, 7, 8 } 
  },
    -- chunk size field not present
  { name = "nil chunk size", field_type = 'I1', filename="I1.bin", write_vector = true, category = "category1",
    input_values = { -128, 0, 127, 11, 5, 6, 7, 8 } 
  },
  --to make sure I1.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from I1.bin, and compare the values in binary file to values got by reading vector
  { name = "valid I1 read", field_type = 'I1', filename="I1.bin", chunk_size = 8, write_vector = false, category = "category1", input_values = { -128, 0, 127, 11, 5, 6, 7, 8 }
  },
  { name = "valid I2", field_type = 'I2', filename="I2.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = { -32768, 0, 32767, 11, 5, 6, 7, 8 } 
  },
  --to make sure I2.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from I2.bin, and compare the values in binary file to values got by reading vector
  { name = "valid I2 read", field_type = 'I2', filename="I2.bin", chunk_size = 8, write_vector = false, category = "category1",
    input_values = { -32768, 0, 32767, 11, 5, 6, 7, 8 } 
  },
  { name = "valid I4", field_type = 'I4', filename="I4.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = { -2147483648, 0, 2147483647, 11, 5, 6, 7, 8 } 
  },
  --to make sure I4.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from I4.bin, and compare the values in binary file to values got by reading vector
  { name = "valid I4 read", field_type = 'I4', filename="I4.bin", chunk_size = 8, write_vector = false, category = "category1",
    input_values = { -2147483648, 0, 2147483647, 11, 5, 6, 7, 8 } 
  },
  { name = "valid F4", field_type = 'F4', filename="F4.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = { -90000000.00, 0, 900000000.00, 11, 5, 6, 7, 8 } 
  },
  --to make sure F4.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from F4.bin, and compare the values in binary file to values got by reading vector
  { name = "valid F4 read", field_type = 'F4', filename="F4.bin", chunk_size = 8, write_vector = false, category = "category1",
    input_values = { -90000000.00, 0, 900000000.00, 11, 5, 6, 7, 8 } 
  },
  { name = "valid SC", field_type = 'SC', filename="SC.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = {  "Stestt", "testt", "Fohff","ddddsw", "dbjcf"} 
  },
  --to make sure SC.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from SC.bin, and compare the values in binary file to values got by reading vector
  { name = "valid SC read", field_type = 'SC', filename="SC.bin", chunk_size = 8, write_vector = false, category = "category1",
    input_values = {  "Stestt", "testt", "Fohff","ddddsw", "dbjcf"} 
  },
  { name = "valid I8", field_type = 'I8', filename="I8.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = { 1,2,3,4,5,6,7,8 } 
  },
  --to make sure I8.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from I8.bin, and compare the values in binary file to values got by reading vector
  { name = "valid I8 read", field_type = 'I8', filename="I8.bin", chunk_size = 8, write_vector = false, category = "category1",
    input_values = { 1,2,3,4,5,6,7,8 } 
  },
  -- valid b1 testcases with number of elements is multiple of 8
  { name = "valid B1", field_type = 'B1', filename="B1.bin", chunk_size = 8, write_vector = true, category = "category2",
    input_values = { 1,0,0,0,0,1,1,1 } 
  },
  --to make sure B1.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from B1.bin, and compare the values in binary file to values got by reading vector
  { name = "valid B1 read", field_type = 'B1', filename="B1.bin", chunk_size = 8, write_vector = false, category = "category2",
    input_values = { 1,0,0,0,0,1,1,1 } 
  },
  -- valid b1 testcases with number of elements is not multiple of 8
  { name = "second valid B1  ", field_type = 'B1', filename="B1.bin", chunk_size = 8, write_vector = true, category = "category2",
    input_values = { 1,0,0,0,0,1,1,1,0 } 
  },
  --to make sure B1.bin is present, run the testcase with write_vector = true first
  -- valid b1 testcases with number of elements is not multiple of 8
  { name = "second valid B1 read", field_type = 'B1', filename="B1.bin", chunk_size = 8, write_vector = false, category = "category2",
    input_values = { 1,0,0,0,0,1,1,1,0 } 
  },
}