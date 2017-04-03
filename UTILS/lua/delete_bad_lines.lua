require 'parser'


function delete_bad_lines(
  infile, 
  outfile, 
  regex_list
  )
    local ifp = assert(io.open(infile, "r"), 
    "Unable to open input file " .. infile .. " for reading")
    local ofp = assert(io.open (outfile, "w"), 
    "Unable to open input file " .. outfile .. " for writing")
    assert(type(regex_list) == "table")

    local num_cols = #regex_list

    for line in ifp:lines() do 
      local entry = parse_csv_line(line, ',')
      local skip = false 
      if #entry ~= num_cols then
        skip = true
      else
        -- now check for all the regex field by field here..
        for i, regex in pairs(regex_list) do
          -- skip regex checking for nil or empty string
          if regex ~= nil and regex ~= "" then 
            start, stop = string.find(entry[i], regex) 
            if not ( ( start ) and ( start == 1 ) and 
              ( stop == string.len(entry[i]) ) ) then 
            -- if ( string.len(x) ~= string.len(entry[i]) ) then 
              skip = true 
              break
            else
              -- print(entry[i], " matches ", regex)
            end
          end 
        end
      end
      if skip == false then
        ofp:write(line, "\n") 
      end 
    end 
    ofp:close()
end
