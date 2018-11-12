from Q import executor
from Q import lupa


class Utils:
    def __init__(self):
        pass

    def to_table_str(self, in_list):
        table_str = ",".join(map(str, in_list))
        table_str = "{%s}" % table_str
        return table_str

    def to_lua_table(self, in_val):
        func_list_to_table = \
            """
            function(items)
                local t = {}
                for index, item in python.enumerate(items) do
                    t[ index+1 ] = item
                end
                return t
            end
            """

        func_dict_to_table = \
            """
            function(d)
                local t = {}
                for key, value in python.iterex(d.items()) do
                    t[ key ] = value
                end
                return t
            end
            """

        func = None
        if type(in_val) == list:
            func = executor.eval(func_list_to_table)
        elif type(in_val) == dict:
            func = executor.eval(func_dict_to_table)
            in_val = lupa.as_attrgetter(in_val)
        else:
            print("Error")
        return func(in_val)
