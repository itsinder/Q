from Q import executor
from Q import lupa
from p_vector import PVector
from p_scalar import PScalar


class Utils:
    def __init__(self):
        pass

    def update_args(self, val):
        if isinstance(val, PVector):
            return val.get_base_vec()
        elif isinstance(val, PScalar):
            return val.get_base_scalar()
        elif type(val) == list:
            new_list = []
            for arg in val:
                new_list.append(self.update_args(arg))
            return self.to_table(new_list)
        elif type(val) == dict:
            new_dict = {}
            for i, v in val.items():
                new_dict[i] = self.update_args(v)
            return self.to_table(new_dict)
        else:
            return val

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
