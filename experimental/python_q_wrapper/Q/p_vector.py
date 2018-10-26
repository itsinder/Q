from Q import executor


class PVector:
    def __init__(self, base_vec):
        self.base_vec = base_vec

    def get_base_vec(self):
        return self.base_vec

    def eval(self):
        """eval the vector"""
        func_str = \
            """
            function(vec)
                return vec:eval()
            end
            """
        func = executor.eval(func_str)
        result = func(self.base_vec)
        return result

    def length(self):
        """returns the vector length"""
        func_str = \
            """
            function(vec)
                return vec:length()
            end
            """
        func = executor.eval(func_str)
        result = func(self.base_vec)
        return result

    def qtype(self):
        """returns the qtype of vector"""
        func_str = \
            """
            function(vec)
                return vec:qtype()
            end
            """
        func = executor.eval(func_str)
        result = func(self.base_vec)
        return result

    def num_elements(self):
        """returns the num_elements of vector"""
        func_str = \
            """
            function(vec)
                return vec:num_elements()
            end
            """
        func = executor.eval(func_str)
        result = func(self.base_vec)
        return result

