subs = { "I1", "I2", "I4", "I8", "F4", "F8" }
subs["F4"] = { 
name = 'txt_to_F4',
out_type_displ = 'F4',
out_type = 'float',
min_val = 'FLT_MIN',
max_val = 'FLT_MAX',
converter = 'strtod',
}, 
subs["F8"] = { 
name = 'txt_to_F8',
out_type_displ = 'F8',
out_type = 'double',
min_val = 'DBL_MIN',
max_val = 'DBL_MAX',
converter = 'strtod',
}

for k, v in ipairs(subs["F4"]) do
  print(k, v)
end
