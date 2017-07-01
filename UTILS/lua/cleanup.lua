local res = require("Q/q_export")
local data_dir = res.Q_DATA_DIR 
local meta_dir = res.Q_META_DATA_DIR
return function()
   os.execute(string.format("find %s -type f -delete", data_dir))
   os.execute(string.format("find %s -type f -delete", meta_dir))
end
