Q = require 'Q'

print(
  Q.sum(
    Q.vvmul(
      Q.const({len = 10, val = 2, qtype = "I4"}),
      Q.const({len = 10, val = 3, qtype = "I4"})
    )
  ):eval()
)
print("========================")


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
