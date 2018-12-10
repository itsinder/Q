from Q import lua_runtime


def eval_lua(code):
    try:
        result = lua_runtime.eval(code)
    except Exception as exc:
        result = None
        print("Exception while evaluating lua code, \nError: {}".format(str(exc)))
    return result


def execute_lua(code):
    try:
        result = lua_runtime.execute(code)
    except Exception as exc:
        print("Exception while executing lua code, \nError: {}".format(str(exc)))
        result = None
    return result

