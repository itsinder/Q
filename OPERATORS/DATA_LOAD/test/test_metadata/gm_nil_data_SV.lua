-- test valid nil data in null allowed SV column 
return { 
  { name = "col1", qtype ="SV",dict = "D1", is_dict = false, add=true, has_nulls =true },
  { name = "col2", qtype = "I4", has_nulls =true } 
}