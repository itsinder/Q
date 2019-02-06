-- TODO P1 Why is this being done here????
local Q_DATA_DIR = os.getenv("Q_DATA_DIR") 
local Q_METADATA_FILE = os.getenv("Q_METADATA_FILE") 

local res = {
    Q_DATA_DIR = Q_DATA_DIR, 
    Q_METADATA_FILE = Q_METADATA_FILE,
}
res.export = function(s, f) 
    res[s] = f
    return f
end

-- Usage of environment variables should be
-- Q.Q_DATA_DIR or
-- Q.QC_FLAGS or ...

return res
