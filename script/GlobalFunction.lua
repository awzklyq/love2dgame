_G._AndOr = function(a, b ,c)
    if c then
        if a then return b else return c end
    else
        if a then return a else return b end
    end
end