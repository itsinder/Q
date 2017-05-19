-- seeded from code on Luvit blog

-- server.lua
dofile 'luvit-loader.lua' -- Enable require to find lit packages

-- This returns a table that is the app instance.
-- All it's functions return the same table for chaining calls.
local tmp
require('weblit-app')

  -- Bind to localhost on port 3000 and listen for connections.
  .bind({
    host = "0.0.0.0",
    port = 3000
  })

  -- Include a few useful middlewares.  Weblit uses a layered approach.
  .use(require('weblit-logger'))
  .use(require('weblit-auto-headers'))
  .use(require('weblit-etag-cache'))

  -- This is a custom route handler
  .route({
    method = "POST", -- Filter on HTTP verb
    path = "/Q", -- Filter on url patterns and capture some parameters.
  }, function (req, res)
    --p(req) -- Log the entire request table for debugging fun
   
    --res.body = "Hello " .. req.params.name .. "\n"
    tmp, res.body = evaluateLine(req.body)
    res.code = 200
  end)

  -- Actually start the server
  .start()

--require('luv').run()