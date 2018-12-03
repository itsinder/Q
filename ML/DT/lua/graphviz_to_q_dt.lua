local plstring = require 'pl.stringx'
local utils = require 'Q/UTILS/lua/utils'
local Scalar = require 'libsclr'
local fns = {}

-- see if the file exists
local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
local function lines_from_file(file)
  if not file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

local function print_dt(
  D,	-- prepared decision tree
  f
)
  if D.left and D.right then
    local label = D.label
    local left_label = D.left.label
    local right_label = D.right.label
    f:write("\"" .. label .. "\" -> \"" .. left_label .. "\"\n")
    f:write("\"" .. label .. "\" -> \"" .. right_label .. "\"\n")

    print_dt(D.left, f)
    print_dt(D.right, f)
  else
    -- No tree available
  end
end

local function modify(D, a, b, features)
  assert(a," a is required")
  local flag = false

  a = plstring.strip(a, " \"")
  b = plstring.strip(b, " \"")
  
  local p_n, p_feature, p_benefit = plstring.splitv(a,'\\n')
  local p_n_T, p_n_H = plstring.splitv(p_n,', ')
  
  local p_n_T_key, p_n_T_value = plstring.splitv(p_n_T,'=')
  local p_n_H_key, p_n_H_value = plstring.splitv(p_n_H,'=')
  local p_benefit_key, p_benefit_value = plstring.splitv(p_benefit,'=')
  local p_feature_key, p_feature_value = plstring.splitv(p_feature,'<=')
  p_feature_key = utils["table_find"](features, p_feature_key)

  local c_n, c_feature, c_benefit = plstring.splitv(b,'\\n')
  local c_n_T, c_n_H = plstring.splitv(c_n,', ')

  local c_n_T_key, c_n_T_value = plstring.splitv(c_n_T,'=')
  local c_n_H_key, c_n_H_value = plstring.splitv(c_n_H,'=')
  
  local c_feature_key, c_feature_value, c_benefit_key, c_benefit_value
  if c_feature and c_benefit then
    c_feature_key, c_feature_value = plstring.splitv(c_feature,'<=')
    c_feature_key = utils["table_find"](features, c_feature_key)
    c_benefit_key, c_benefit_value = plstring.splitv(c_benefit,'=')
    c_feature_value = tonumber(c_feature_value)
    c_benefit_value = tonumber(c_benefit_value)
  end
  
  if c_feature_key then
    flag = true
  end
  
  if D.label == nil then
    D.label = a
    D[p_n_T_key] = tonumber(p_n_T_value)
    D[p_n_H_key] = tonumber(p_n_H_value)
    D.feature =  p_feature_key
    D.threshold = tonumber(p_feature_value)
    D[p_benefit_key] = tonumber(p_benefit_value)
    
    D.left = {}
    D.left.label = b
    D.left[c_n_T_key] = tonumber(c_n_T_value)
    D.left[c_n_H_key] = tonumber(c_n_H_value)
    if flag == true then
      D.left.feature = c_feature_key
      D.left.threshold = c_feature_value
      D.left[c_benefit_key] = c_benefit_value
    end
    
  elseif  D.label == a and D.left == nil then
    D.left = {}
    D.left.label = b
    D.left[c_n_T_key] = tonumber(c_n_T_value)
    D.left[c_n_H_key] = tonumber(c_n_H_value)
    if flag == true then
      D.left.feature = c_feature_key
      D.left.threshold = c_feature_value
      D.left[c_benefit_key] = c_benefit_value
    end  
  elseif  D.label == a and D.right == nil then
    D.right = {}
    D.right.label = b
    D.right[c_n_T_key] = tonumber(c_n_T_value)
    D.right[c_n_H_key] = tonumber(c_n_H_value)
    if flag == true then
      D.right.feature = c_feature_key
      D.right.threshold = c_feature_value
      D.right[c_benefit_key] = c_benefit_value
    end
  end
  if D.label ~= a and D.left ~= nil then
    modify(D.left, a, b, features)
  end
  if D.label ~= a and D.right ~= nil then
    modify(D.right, a, b, features)
  end
end

local function graphviz_to_D(file, features)
  local lines = lines_from_file(file)

  local D = {}
  -- print all line numbers and their contents
  for k,v in pairs(lines) do
    if k>3 then
      local a, b = plstring.splitv(v,'->')
      if a then 
        a= plstring.strip(a)
      end
      if b then 
        b= plstring.strip(b)
      end
      if a and b then
        modify(D, a, b, features)
     else
       -- nothing to do
     end
    end
  end
  return D
end

fns.graphviz_to_D = graphviz_to_D
fns.print_dt = print_dt

return fns
