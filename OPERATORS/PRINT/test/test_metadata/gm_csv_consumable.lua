-- test whether csv generated by print_csv is consumed/loaded by load_csv properly
return { 
  { name = "col1", has_nulls =true, qtype = "I4" },
  { name = "col2", qtype ="I2" },
  { name = "col3", qtype ="SV",dict = "D1", is_dict = false, add=true}
}