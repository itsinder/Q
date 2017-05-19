--local utils = require('lib/utils')
-- dofile 'init.lua'

local buffer = ''

local function gatherResults(success, ...)
  local n = select('#', ...)
  return success, { n = n, ... }
end

local function printResults(results)
  for i = 1, results.n do
    results[i] = require('luv_utils').dump(results[i])
  end
  print(table.concat(results, '\t'))
end

prompt = "q>"

function evaluateLine(line)
  if line == "<3\n" then
    print("I " .. c("Bred") .. "♥" .. c() .. " you too!")
    return '>'
  end
  local chunk  = buffer .. line
  local f, err = loadstring('return ' .. chunk, 'REPL') -- first we prefix return

  if not f then
    f, err = loadstring(chunk, 'REPL') -- try again without return
  end

  if f then
    buffer = ''
    local success, results = gatherResults(xpcall(f, debug.traceback))

    if success then
      -- successful call
      if results.n > 0 then
        printResults(results)
      end
    else
      -- error
      print(results[1])
    end
  else

    if err:match "'<eof>'$" then
      -- Lua expects some more input; stow it away for next time
      buffer = chunk .. '\n'
      return '>>'
    else
      print(err)
      buffer = ''
    end
  end

  return prompt
end

require 'q_httpserver'
require 'q_repl'
-- We also need to explicitly start the libuv event loop.
require('luv').run()