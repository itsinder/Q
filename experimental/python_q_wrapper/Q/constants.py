supported_dtypes = ["I1", "I2", "I4", "I8", "F4", "F8"]


# Q data types
I1 = "I1"
I2 = "I2"
I4 = "I4"
I8 = "I8"
F4 = "F4"
F8 = "F8"


# data types that resembles with numpy
int8 = "I1"
int16 = "I2"
int32 = "I4"
int64 = "I8"
float32 = "F4"
float64 = "F8"


# operator names
MK_COL = "mk_col"
CONST = "const"
ADD = "add"
SEQ = "seq"


# scalar function strings
scalar_arith_func_str = \
    """
    function(scalar1, scalar2)
        return scalar1 {op} scalar2
    end
    """

scalar_func_str = \
    """
    function(scalar)
        return scalar:{fn_name}()
    end
    """

# vec function strings
vec_func_str = \
    """
    function(vec)
        return vec:{fn_name}()
    end
    """

vec_func_arg_str = \
    """
    function(vec, arg_val)
        return vec:{fn_name}(arg_val)
    end
    """
