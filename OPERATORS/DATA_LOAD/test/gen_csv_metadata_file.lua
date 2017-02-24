package.path = package.path .. ";../lua/?.lua"
require 'globals'
require 'pl'

local function escape_csv (s)
  if string.find(s, '[,"]') then
    s = '"' .. string.gsub(s, '"', '""') .. '"'
  end
  return s
end

local function to_csv (tt)
  local s = ""
  for _,p in ipairs(tt) do  
    s = s .. "," .. escape_csv(p)
  end
    return(string.sub(s, 2))    -- TODO:  move out this statement
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

--generating metadata table(returns metadata table generated)
function generate_metadata(List)
  
  local metadata_table= {}
  local idx=1
  local col_name= 'col'
  
  for i=1, #List do
    for k = 1 , List[i]['column_count'] do
      metadata_table[idx] = {}
      if List[i]['type']== 'SC' then
        metadata_table[idx]['name'] = col_name ..idx
        metadata_table[idx]['type'] = List[i]['type']
        metadata_table[idx]['size'] = List[i]['size']
        metadata_table[idx]['null'] = List[i]['null']
        idx = idx +1
      elseif List[i]['type']== 'SV' then
        metadata_table[idx]['name'] = col_name ..idx
        metadata_table[idx]['type'] = List[i]['type']
        metadata_table[idx]['size'] = List[i]['size']
        metadata_table[idx]['null'] = List[i]['null']
        metadata_table[idx]['dict'] = List[i]['dict']
        metadata_table[idx]['is_dict'] = List[i]['is_dict']
        metadata_table[idx]['add'] = List[i]['add']
        idx = idx +1
      else
        metadata_table[idx]['name'] = col_name ..idx
        metadata_table[idx]['type'] = List[i]['type']
        metadata_table[idx]['null'] = List[i]['null']
        idx = idx +1
      end
    end
  end
  return metadata_table
end

--function to fill the chunk_print_size table with data
local function fill_table(column_list, chunk_print_size)
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
        func ='random_'..column_list[j]['type']
        loadstring("value = " .. func)()
        local size = column_list[j]['size']-1
        table.insert(file_data[ind],value(size))
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
function generate_csv_file(csv_file_name, column_list, row_count, chunk_print_size)
  
  local file = assert(io.open(csv_file_name, 'w')) 
  local no_of_chunks = math.floor(row_count/chunk_print_size)
  local chunks = 1
  local table_data = { }
  local rows = 0 
  
  while( chunks <= no_of_chunks) do
    table_data = fill_table(column_list,chunk_print_size)
    write_and_empty_table(chunk_print_size, table_data, file)
    chunks = chunks + 1
    rows = rows + chunk_print_size
  end
  
  --for the last chunk
  local last_chunk_rows = no_of_chunks*chunk_print_size
  local last_chunk_print_size = 0
  
  if(last_chunk_rows< row_count)then
    last_chunk_print_size = row_count - last_chunk_rows
    table_data = fill_table(column_list,last_chunk_print_size)
    write_and_empty_table(last_chunk_print_size, table_data, file)
  end
  
  rows = rows + last_chunk_print_size
  io.close(file)
  return rows
end
