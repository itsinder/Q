require 'parser'


function delete_bad_lines(input_file_path, output_file_path , regex_list)
  local input_file = assert(io.open(input_file_path, "r"))
  local output_file = assert(io.open (output_file_path, "w"))
  
  local num_cols = #regex_list
  
  for line in input_file:lines() do 
    local entry= parse_csv_line(line, ',')
    print("Num of columns " .. #entry)
    -- consider only if number of columns matches
    if #entry == num_cols then
      local skip = false 
      -- now check for all the regex field by field here..
      for i, regex in pairs(regex_list) do
        -- skip regex checking for nil or empty string
        if regex ~= nil and regex ~= "" then 
          print(string.find(entry[i], regex))
          if string.find(entry[i], regex) ~= nil then
            print("skipped")
            skip = true 
            break
          end
        end 
      end
      if skip == false then
        output_file:write(line, "\n") 
      end
    end 
  end 

end

local regexs = {
  "%d",
  ""
}
delete_bad_lines("in_file.csv", "out_file.csv", regexs)