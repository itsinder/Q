
    if type(x) == "Column" and type(y) == "Column" then
        local status, col = pcall(expander_f1f2opf3, vv<<operator>>, x, y)
        if ( not status ) then print(col) end
        assert(status, "Could not execute vv<operator>>")
        return col
    end
