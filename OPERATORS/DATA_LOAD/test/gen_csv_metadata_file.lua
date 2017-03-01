package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"

require 'globals'
require 'pl'

--Used to escape "'s , so that string can be inserted in csv line
local function escape_csv (s)
  if string.find(s, '[,"]') then
    s = '"' .. string.gsub(s, '"', '""') .. '"'
  end
  return s
end

--to convert row (table) into comma separated line
local function to_csv (tt)
  local s = ""
  for _,p in ipairs(tt) do  
    s = s .. "," .. escape_csv(p)
  end
    return(string.sub(s, 2))
end

--placing random seed once at start for generating random no. each time
math.randomseed(os.time())

function random_int8_t()
  return math.random(1,127)
end

function random_int16_t()
  return math.random(1,32767)
end

function random_int32_t()
  return math.random(1,2147483647)
end

function random_float()
  return math.random(100000,900000) / 10
end

local charset = {}
-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i))  end
for i = 65,  90 do table.insert(charset, string.char(i))  end
for i = 97, 122 do table.insert(charset, string.char(i))  end

function random_SC(length_inp)
    local length = length_inp
    if length > 0 then
        return random_SC(length - 1) .. charset[math.random(1, #charset)]
    end
    return ""
end

function random_SV(size)
    random_len = math.random(1,size)
    string = random_SC(random_len)
    return string
end

--generating maximum specified unique strings
local function dict_size_unique_string(max_str_size, max_idx)
  local str
  local unique_strings_table = { } --for storing unique strings in table
  local reverse_storing = { } --for searching string in 0(n) time
  local idx = 1

  repeat  
    str = random_SV(max_str_size-1)
    if(reverse_storing[str] == nil) then 
      --generated string is not in the table then insert in both the tables 
      unique_strings_table[idx] = str
      reverse_storing[str] = idx
      idx = idx + 1
    end
  until idx == max_idx + 1
  
  return unique_strings_table
end

--generating unique strings for each varchar column
function generate_unique_varchar_strings(meta_info)
  local unique_string_tables = {}
  local is_varchar_col = false
  
  for i=1, #meta_info do
    if meta_info[i]['type']=='SV' then
      is_varchar_col= true
      
      --calculating possible unique string limit
      local exp_unique_strings= 0
      for i=1, meta_info[i]['size']-1 do
        exp_unique_strings = exp_unique_strings + math.pow(#charset, i)
      end
      print("For string length ",meta_info[i]['size']-1," value is ",exp_unique_strings)
      
      -- before gen unique strings checking if max_unique_value is within possible limit
      if meta_info[i]['max_unique_values'] <= exp_unique_strings then
        unique_string_tables[i] = {}
        unique_string_tables[i] = dict_size_unique_string(meta_info[i]['size'],meta_info[i]['max_unique_values'])
      else
        print(meta_info[i]['max_unique_values'],"is beyond possible limit value...")
        os.exit()
      end
    end
  end  
  
  if is_varchar_col == false then
    return false
  else
    --pretty.dump(unique_string_tables[2])
    --print("table size",#unique_string_tables[2])
    return unique_string_tables
  end
end


--generating metadata table(returns metadata table generated)
function generate_metadata(meta_info)
  
  local metadata_table= {}
  local idx=1
  local col_name= 'col' --for giving names to each column
  
  for i=1, #meta_info do
    for k = 1 , meta_info[i]['column_count'] do
      metadata_table[idx] = {}
      if meta_info[i]['type']== 'SC' then
        metadata_table[idx]['name'] = col_name ..idx
        metadata_table[idx]['type'] = meta_info[i]['type']
        metadata_table[idx]['size'] = meta_info[i]['size']
        metadata_table[idx]['null'] = meta_info[i]['null']
        idx = idx +1
      elseif meta_info[i]['type']== 'SV' then
        metadata_table[idx]['name'] = col_name ..idx
        metadata_table[idx]['type'] = meta_info[i]['type']
        metadata_table[idx]['size'] = meta_info[i]['size']
        metadata_table[idx]['null'] = meta_info[i]['null']
        metadata_table[idx]['add'] = meta_info[i]['add']
        metadata_table[idx]['dict'] = "D"..i
        metadata_table[idx]['unique_table_id']= i
        metadata_table[idx]['max_unique_values'] = meta_info[i]['max_unique_values']
        if k==1 then
          metadata_table[idx]['is_dict'] = false
        else
          metadata_table[idx]['is_dict'] = true
        end
        idx = idx +1
      else
        metadata_table[idx]['name'] = col_name ..idx
        metadata_table[idx]['type'] = meta_info[i]['type']
        metadata_table[idx]['null'] = meta_info[i]['null']
        idx = idx +1
      end
    end
  end
  pretty.dump(metadata_table)
  return metadata_table
end


--function to fill the chunk_print_size table with data
local function fill_table(column_list, chunk_print_size,unique_string_tables)
  local file_data = { }
  local col_length = #column_list
  
  for ind=1, chunk_print_size do
    --fill table data
    file_data[ind] = {}
    for j=1, col_length do
      --if col is other than SC and SV
      if column_list[j]['type']=='SC' then
        func ='random_'..column_list[j]['type']
        loadstring("value = " .. func)()
        local size = column_list[j]['size']-1
        table.insert(file_data[ind],value(size))
      elseif column_list[j]['type']=='SV' then
        local random_no = math.random(1,column_list[j]['max_unique_values'])
        local dict_no = column_list[j]['unique_table_id']
        --print("col no:",j,"dict no:",dict_no)
        table.insert(file_data[ind],unique_string_tables[dict_no][random_no])
      else
        local data_type_short_code = column_list[j]['type']
        local func ='random_'..g_qtypes[data_type_short_code]['ctype']
        loadstring("value = " .. func)()
        table.insert(file_data[ind],value())
      end
    end
  end
  return file_data  
end

--function to write the table data into csv file and then empty the table
local function write_and_empty_table(chunk_print_size, file_data, file)
  local final_csv_string = ''
  for ind=1, chunk_print_size do
    --write file data and empty table data
    local csv_string = to_csv(file_data[ind])
    final_csv_string = final_csv_string..csv_string.."\n"
    file_data[ind]=nil
  end
   file:write(final_csv_string)
end


--generating csv file based on metadata (this function returns no of rows generated)
function generate_csv_file(csv_file_name, metadata_table, row_count, chunk_print_size,unique_string_tables)
  
  local file = assert(io.open(csv_file_name, 'w')) 
  local no_of_chunks = math.floor(row_count/chunk_print_size)
  local chunks = 1
  local table_data = { }
  local rows = 0 
  
  while( chunks <= no_of_chunks) do
    table_data = fill_table(metadata_table, chunk_print_size, unique_string_tables)
    write_and_empty_table(chunk_print_size, table_data, file)
    chunks = chunks + 1
    rows = rows + chunk_print_size
  end
  
  --for the last chunk
  local last_chunk_rows = no_of_chunks*chunk_print_size
  local last_chunk_print_size = 0
  
  if(last_chunk_rows< row_count)then
    last_chunk_print_size = row_count - last_chunk_rows
    table_data = fill_table(metadata_table, last_chunk_print_size, unique_string_tables)
    write_and_empty_table(last_chunk_print_size, table_data, file)
  end
  
  rows = rows + last_chunk_print_size
  io.close(file)
  return rows
end
