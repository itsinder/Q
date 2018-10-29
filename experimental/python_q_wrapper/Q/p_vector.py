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
        return self

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

    def set_name(self, name):
        """sets the name of a vector"""
        func_str = \
            """
            function(vec, name)
                return vec:set_name(name)
            end
            """
        func = executor.eval(func_str)
        result = func(self.base_vec, name)
        return self

    def get_name(self):
        """returns the name of a vector"""
        func_str = \
            """
            function(vec)
                return vec:get_name()
            end
            """
        func = executor.eval(func_str)
        result = func(self.base_vec)
        return result

    def memo(self, is_memo):
        """sets the memo value for vector"""
        func_str = \
            """
            function(vec, is_memo)
                return vec:memo(is_memo)
            end
            """
        func = executor.eval(func_str)
        result = func(self.base_vec, is_memo)
        return self

    def is_memo(self):
        """returns memo value for vector"""
        func_str = \
            """
            function(vec)
                return vec:is_memo()
            end
            """
        func = executor.eval(func_str)
        result = func(self.base_vec)
        return result

    def persist(self, is_persist):
        """sets the persist flag for vector"""
        func_str = \
            """
            function(vec, is_persist)
                return vec:persist(is_persist)
            end
            """
        func = executor.eval(func_str)
        result = func(self.base_vec, is_persist)
        return self

