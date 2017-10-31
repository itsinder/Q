from ipykernel.kernelbase import Kernel
from lupa import LuaRuntime

class EchoKernel(Kernel):
    implementation = 'Echo'
    implementation_version = '1.0'
    language = 'no-op'
    language_version = '0.1'
    language_info = {
        'name': 'Any text',
        'mimetype': 'text/plain',
        'file_extension': '.txt',
    }
    banner = "Echo kernel - as useful as a parrot"
    
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute("Q = require 'Q'")
    """
    with open("/tmp/sample.txt", "a") as f:
        f.write(str(lua))
        f.write("\n")
    """

    def do_execute(self, code, silent, store_history=True, user_expressions=None,
                   allow_stdin=False):
        if not silent:
            result = EchoKernel.lua.execute(code)
            stream_content = {'name': 'stdout', 'text': str(result)}
            self.send_response(self.iopub_socket, 'stream', stream_content)

        return {'status': 'ok',
                # The base class increments the execution count
                'execution_count': self.execution_count,
                'payload': [],
                'user_expressions': {},
               }
