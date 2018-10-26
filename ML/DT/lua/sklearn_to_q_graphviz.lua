local plstring = require 'pl.stringx'
local utils = require 'Q/UTILS/lua/utils'
local plpath = require 'pl.path'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local path_to_here = Q_SRC_ROOT .. "/ML/DT/lua/"
assert(plpath.isdir(path_to_here))
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

local function split_labels_n_links(lines_tbl)
  local label_tbl = {}
  local links_tbl = {}
  for k,v in pairs(lines_tbl) do
    if k>3 then
      if (string.find(v, "->")) ~= nil then
        v = plstring.strip(v) 
        local links, label = plstring.splitv(v, " %[")
        links = plstring.strip(links, ";")
        links_tbl[#links_tbl + 1] = links
      elseif v ~= "}" then
        v = plstring.strip(v)
        local index, label = plstring.splitv(v, " %[label=<")
        index = tonumber(index)
        label = plstring.splitv(label, ">, ")
        -- storing labels according to it node index only
        assert(#label_tbl == index)
        label_tbl[#label_tbl + 1] = label
      end
    end
  end
  return label_tbl, links_tbl
end

local function value_to_n_T_n_H (value)
  local idx_s = string.find(value, "%[")
  local idx_e = string.find(value, "%]")
  local str_out = string.sub(value, idx_s+1, idx_e-1)
  local val_1, val_2 = plstring.splitv(str_out, ", ")
  local n_T_n_H = "n_T=" .. val_1 .. ", n_H=" .. val_2
  return n_T_n_H
end

local function get_condition(condition)
  local feature, threshold = plstring.splitv(condition, "; ")
  feature = plstring.splitv(feature, " &")
  local feature_threshold = feature .. "<=" .. threshold
  return feature_threshold
end

local function get_benefit(label)
  local key, value
  key, value = plstring.splitv(label, "= ")
  return value
end

local function get_required_fields(label_tbl)
  local q_field_labels = {}
  for i=1, #label_tbl do
    local l1, l2, l3, l4 = plstring.splitv(label_tbl[i], "<br/>")
    if l4 ~= nil then
      l4 = value_to_n_T_n_H(l4)
      l1 = get_condition(l1)
      l2 = get_benefit(l2)
      local str = l4 .. "\\n" .. l1 .. "\\n" .. "benefit=" ..l2
      q_field_labels[#q_field_labels + 1] = str
    else
      l3 = value_to_n_T_n_H(l3)
      local str = l3
      q_field_labels[#q_field_labels + 1] = str
    end
  end
  return q_field_labels
end

local function print_to_file(links, labels)
  -- print q format to graphviz file
  local f = io.open(path_to_here .."gini_to_q_graphviz.txt", "w")
  f:write("digraph Tree {\n")
  f:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
  f:write("edge [fontname=helvetica] ;\n")
  
  for k,v in pairs(links) do
    --f:write()
    local parent_idx, child_idx = plstring.splitv(v, "->")
    f:write("\"" .. labels[tonumber(parent_idx+1)] .. "\" -> \"" .. labels[tonumber(child_idx+1)] .. "\"\n")
  end

  f:write("}\n")
  f:close()
end

local function gini_to_q_graphviz(file)
  local lines_tbl = lines_from_file(file)
  assert(type(lines_tbl) == "table")
  local label_tbl, links_tbl = split_labels_n_links(lines_tbl)
  label_tbl = get_required_fields(label_tbl)
  print_to_file(links_tbl, label_tbl)
  print("Outputted the q format to " .. path_to_here .."gini_to_q_graphviz.txt" )
  return path_to_here .."gini_to_q_graphviz.txt"
end

fns.gini_to_q_graphviz = gini_to_q_graphviz

return fns
