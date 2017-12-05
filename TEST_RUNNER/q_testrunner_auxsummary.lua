test_aux = function (test_res)
    local cnt = {
        suites = {pass = 0, fail = 0},
        tests = {pass = 0, fail = 0}
    }
    for _,t in pairs(test_res) do
        cnt.tests.pass = cnt.tests.pass + #t.pass
        cnt.tests.fail = cnt.tests.fail + #t.fail
        if #t.fail == 0 then
            cnt.suites.pass = cnt.suites.pass + 1
        else
            cnt.suites.fail = cnt.suites.fail + 1
        end
    end
    local plpretty = require "pl.pretty"
    local summary = plpretty.write(cnt, "")

    if cnt.tests.fail == 0 then 
        print ("SUCCESS " .. summary) else print ("FAILURE " .. summary)
    end
end