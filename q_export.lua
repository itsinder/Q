local Q_DATA_DIR = os.getenv("Q_DATA_DIR") -- TODO default
if not Q_DATA_DIR then Q_DATA_DIR = os.getenv("HOME") .. "/Q/DATA_DIR" end
local Q_META_DATA_DIR = os.getenv("Q_METADATA_DIR") -- TODO default
if not Q_META_DATA_DIR then Q_META_DATA_DIR = os.getenv("HOME") .. "/Q/METADATA_DIR" end

print (Q_DATA_DIR)
local pldir = require 'pl.dir'
pldir.makepath(Q_DATA_DIR)
pldir.makepath(Q_META_DATA_DIR)

local res = {
    Q_DATA_DIR = Q_DATA_DIR, 
    Q_META_DATA_DIR = Q_META_DATA_DIR,
}
res.export = function(s, f) 
    res[s] = f
    return f
end

return res