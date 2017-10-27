local Q       = require 'Q'

local function load_data(
  file_name, 
  data_file,  -- name of TGZ file containing data 
  num_cols -- number of columns in training data (not including label)
)
  local meta_file = 'LR-test-' .. file_name .. '.lua'
  local status = pcall(dofile, os.getenv("Q_METADATA_DIR")..'/'..meta_file)
  if not status or not train_X or not train_y or not test_X or not test_y then
    local data_folder = 'data'

    os.execute('mkdir -p ' .. data_folder)
    os.execute('tar -xzf '.. data_file .. ' -C ' .. data_folder)

    local prefix = data_folder .. '/' .. file_name .. '/'
    local train_X_file = prefix .. 'train_data.csv'
    local train_y_file = prefix .. 'train_labels.csv'
    local test_X_file  = prefix .. 'test_data.csv'
    local test_y_file  = prefix .. 'test_labels.csv'

    function cols(suff)
      local x_cols = {}
      for i = 1, num_cols do
        local xname = 'x_' .. i .. suff
        x_cols[i] = { name = xname, qtype = "F8", has_nulls = false}
      end
      local yname = 'y_' ..  suff
      local y_cols = { { name = yname, qtype = "F8", has_nulls = false}}
      return x_cols, y_cols
    end
    local x_cols, y_cols = cols('train')
    train_X = Q.load_csv(train_X_file, x_cols)
    print('loaded train_X')
    train_y = Q.load_csv(train_y_file, y_cols)[1]
    print('loaded train_y')
    
    x_cols, y_cols = cols('test')
    test_X = Q.load_csv(test_X_file, x_cols)
    print('loaded test_X')
    test_y = Q.load_csv(test_y_file, y_cols)[1]
    print('loaded test_y')
  end
  return train_X, train_y, test_X, test_y
end
return load_data
