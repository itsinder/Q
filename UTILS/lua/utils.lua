require 'pl'



function valid_dir(dir_path)
    if( dir_path == nil or not path.exists(dir_path) or not path.isdir(dir_path) ) then 
      return false 
    else 
      return true 
    end
end

function valid_file(file_path)
    if( file_path == nil or not path.exists(file_path) or not path.isfile(file_path) ) then 
      return false 
    else 
      return true 
    end
end
