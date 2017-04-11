-- Specify script in order in which they should run
local T = {}
T[#T+1] = { dir = "/UTILS/src/", scripts = { "gen_files.sh" } }
T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/lua/", scripts = { "gen_files.sh" }}
T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/src/", scripts = { "gen_files.sh" }}
T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/test/", scripts = { "test_get_cell.sh" }}
T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/test/", scripts = { "test_load.sh" }}
T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/test/testcases/", scripts = { "test_meta_data.sh" }}
T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/test/testcases/", scripts = { "test_load_csv.sh" }}
T[#T+1] = { dir = "/OPERATORS/PRINT/test/", scripts = { "test_print.sh" }}
T[#T+1] = { dir = "/OPERATORS/PRINT/test/", scripts = { "test_print_csv.sh" }}
T[#T+1] = { dir = "/OPERATORS/F1F2OPF3/lua/", scripts = { "gen_files.sh" }}
T[#T+1] = { dir = "/OPERATORS/F1S1OPF2/lua/", scripts = { "gen_files.sh" }}
T[#T+1] = { dir = "/OPERATORS/F_TO_S/lua/", scripts = { "gen_files.sh"}}
return T
