local X = {}

local fns = {}
for i = 1, 2 do 
  fns[i] = function()
    print("My X= ", i, X[i])
  end
end

X[1] = "abc"
X[2] = "def"
fns[1]()
fns[1]()
fns[1]()
fns[1]()
fns[2]()
