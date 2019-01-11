import Q.src.lua_executor as executor
from Q.src.constants import list_to_table_str, dict_to_table_str
from Q import lupa


def is_p_vector(val):
    from Q.src.p_vector import PVector
    return isinstance(val, PVector)


def is_p_scalar(val):
    from Q.src.p_scalar import PScalar
    return isinstance(val, PScalar)


def is_p_reducer(val):
    from Q.src.p_reducer import PReducer
    return isinstance(val, PReducer)


def is_valid_arg():
    pass


def unpack_args(val):
    if is_p_vector(val):
        return val.get_base_vec()
    elif is_p_scalar(val):
        return val.get_base_scalar()
    elif type(val) == list:
        new_list = []
        for arg in val:
            new_list.append(unpack_args(arg))
        return to_table(new_list)
    elif type(val) == dict:
        new_dict = {}
        for i, v in val.items():
            new_dict[i] = unpack_args(v)
        return to_table(new_dict)
    else:
        return val


def to_table(in_val):
    func = None
    if type(in_val) == list:
        func = executor.eval_lua(list_to_table_str)
    elif type(in_val) == dict:
        func = executor.eval_lua(dict_to_table_str)
        in_val = lupa.as_attrgetter(in_val)
    else:
        print("Error")
    return func(in_val)


def to_list(in_table):
    # TODO: check type of in_table, it should be lua table
    return list(in_table)


def to_dict(in_table):
    # TODO: check type of in_table, it should be lua table
    return list(in_table)


def to_list_or_dict(in_table):
    # TODO: check type of in_table, it should be lua table
    return dict(in_table)
