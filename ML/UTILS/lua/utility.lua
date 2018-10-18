local fns = {}
local function load_csv_col_seq(col_names)
  local col_names_load = {}
  for i = 1, #col_names do 
    col_names_load[col_names[i]] = i 
  end
  
  local col_upd = {}
  for i,v in pairs(col_names_load) do
    col_upd[#col_upd + 1] = i
  end
  
  local col_upd_copy = {}
  for i,v in pairs(col_upd) do
    col_upd_copy[v] = i
  end
  
  local T = {} 
  for idx, value in pairs(col_upd_copy) do
    T[#T+1] = idx
  end
  
  return T
end

fns.load_csv_col_seq = load_csv_col_seq

return fns