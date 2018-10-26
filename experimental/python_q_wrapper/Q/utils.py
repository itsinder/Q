from Q import executor


class Utils:
    def __init__(self):
        pass

    def to_table_str(self, in_list):
        table_str = ",".join(map(str, in_list))
        table_str = "{%s}" % table_str
        return table_str

    def to_lua_table(self, in_list):
        func_str = \
            """
            function(items)
                local t = {}
                for index, item in python.enumerate(items) do
                    t[ index+1 ] = item
                end
                return t
            end
            """
        func = executor.eval(func_str)
        return func(in_list)
