Q = require 'Q'

local tests = {}
tests.t1 = function ()
print(
  Q.sum(
    Q.vvmul(
      Q.const({len = 10, val = 2, qtype = "I4"}),
      Q.const({len = 10, val = 3, qtype = "I4"})
    )
  ):eval()
)
print("========================")
end
--======================================
tests.t2 = function ()


print(
  Q.sum(
    Q.vvmul(
      Q.const({len = 10, val = 2, qtype = "I4"}),
      Q.vvsub(
        Q.const({len = 10, val = 7, qtype = "I4"}),
        Q.logit(
          Q.const({len = 10, val = 3, qtype = "F4"})
        )
      )
    )
  ):eval()
)

end
--======================================
return tests
