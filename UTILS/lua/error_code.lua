g_err = {}

-- load error codes
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

-- meta data codes
g_err.METADATA_NULL_ERROR = "Metadata should not be nil"
g_err.METADATA_TYPE_TABLE = "Metadata type should be table"
g_err.METADATA_NAME_NULL = " - name cannot be null"
g_err.METADATA_TYPE_NULL = " - type cannot be null"
g_err.INVALID_QTYPE = " - type contains invalid q type"
g_err.INVALID_NN_BOOL_VALUE = " - null can contain true/false only"
g_err.DUPLICATE_COL_NAME = " - duplicate column name is not allowed"
g_err.SC_SIZE_MISSING = " - size should be specified for fixed length strings"
g_err.SC_INVALID_SIZE = " - size should be valid number"
g_err.DICT_NULL_ERROR = " - dict cannot be null"
g_err.IS_DICT_NULL = " - is_dict cannot be null"
g_err.INVALID_IS_DICT_BOOL_VALUE = " - is_dict can contain true/false only"
g_err.ADD_DICT_ERROR = " - add cannot be null for dictionary which has is_dict true"
g_err.INVALID_ADD_BOOL_VALUE = " - add can contain true/false only"

