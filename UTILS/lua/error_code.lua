g_err = {}
-- currently only 2 error codes are added.
-- once approved with this approach , will include rest
-- and also use these global error codes in load and print lua files
g_err.INVALID_DATA_ERROR = "Invalid data found"
g_err.INVALID_INDEX_ERROR = "Index has to be valid"
g_err.NULL_IN_NOT_NULL_FIELD = "Null value found in not null field"
g_err.CSV_FILE_PATH_INCORRECT = "csv_file_path is not correct"
g_err.STRING_GREATER_THAN_SIZE = "contains string greater than allowed size. Please correct data or metadata."
g_err.FILE_EMPTY = "File should not be empty"
g_err.Q_DATA_DIR_INCORRECT = "Q_DATA_DIR is not pointing to correct directory"
g_err.Q_META_DATA_DIR_INCORRECT = "Q_META_DATA_DIR is not pointing to correct directory"
g_err.ERROR_CREATING_ACCESSING_DICT = "Error while creating/accessing dictionary for M" 
g_err.MMAP_FAILED = "Mmap failed"
g_err.FILE_EMPTY = "File cannot be empty"