from Q import executor
from Q import lupa


class Utils:
    def __init__(self):
        pass

    def to_table(self, in_val):
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

    def to_list(self, in_table):
        # TODO: check type of in_table, it should be lua table
        return list(in_table)

    def to_dict(self, in_table):
        # TODO: check type of in_table, it should be lua table
        return list(in_table)

    def to_list_or_dict(self, in_table):
        # TODO: check type of in_table, it should be lua table
        return dict(in_table)
