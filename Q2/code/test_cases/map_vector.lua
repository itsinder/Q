return {
  
  -- checks the name of the binary file created by calling eov function in vector class
  { name = "valid I1", field_type = 'I1', filename="I1.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = { -128, 0, 127, 11, 5, 6, 7, 8 } 
  },
  { name = "valid I2", field_type = 'I2', filename="I2.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = { -32768, 0, 32767, 11, 5, 6, 7, 8 } 
  },
  { name = "valid I4", field_type = 'I4', filename="I4.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = { -2147483648, 0, 2147483647, 11, 5, 6, 7, 8 } 
  },
  { name = "valid F4", field_type = 'F4', filename="F4.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = { -90000000.00, 0, 900000000.00, 11, 5, 6, 7, 8 } 
  },
  { name = "valid SC", field_type = 'SC', filename="SC.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = {  "Stestt", "testt", "Fohff","ddddsw", "dbjcf"} 
  },
  { name = "valid I8", field_type = 'I8', filename="I8.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = { 1,2,3,4,5,6,7,8 } 
  },
  
 
}