local get_f_fops = function(npl, nI)
  local cnt = 0
  for i = 2, #npl do
    local factor
    if i==#npl then
      factor = 6
    else
      factor = 2
    end
    cnt = cnt + (npl[i-1] * npl[i] * nI * factor)
  end
  return cnt + npl[1]
end

local get_b_fops = function(npl, nI)
  local cnt = 0
  local da_last_fops = npl[#npl] * nI * 5
  local factor
  for i = #npl, 2, -1 do
    local dz_fops = 0
    if i == #npl then
      dz_fops = npl[i] * nI * 7
    end
    local da_prev_fops = npl[i] * npl[i-1] * nI * 2
    if i == 2 then
      da_prev_fops = 0
    end
    local dw_fops = npl[i] * npl[i-1] * nI * 2 + npl[i] * npl[i-1] * 1
    local db_fops = npl[i] * nI + npl[i] * 1
    cnt = cnt + dz_fops + da_prev_fops + dw_fops + db_fops
  end
  return cnt + da_last_fops
end

local get_update_wb_fops = function(npl)
  local cnt = 0
  for i = 2, #npl do
    local w_fops = npl[i-1] * npl[i] * 2
    local b_fops = npl[i] * 2
    cnt = cnt + w_fops + b_fops
  end
  return cnt
end

local npl -- network structure 
local nI  -- number of instances
npl = { 9, 7, 2, 1 }
npl = { 128, 64, 32, 16, 8, 4, 2, 1 }
--local ld_tbl = {18,10,13,7,4,2,1}
nI = 5
nI = 1024 * 1024 
local num_epoch = 1
local f_fops = get_f_fops(npl, nI)
print(f_fops)
local b_fops = get_b_fops(npl, nI)
print(b_fops)
local wb_fops = get_update_wb_fops(npl)
print(wb_fops)
print(f_fops+b_fops+wb_fops)
