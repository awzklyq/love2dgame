local testfunc = function(c, d)
    local num = 1000
    for i = 1, num do
        log('Deal Data-> ', i)
        if i % 50 == 0 then
            coroutine.yield(i)
        end 
    end
end

local co = coroutine.create(testfunc)

-- log('aaaaaa', coroutine.status(co))
-- for i, v in pairs(coroutine) do
--     log('uuu', i, v)
-- end

app.update(function(dt)
    if "dead" ~= coroutine.status(co) then
        
        local _, result = coroutine.resume(co)
        log('the yield return: ', result)
    end
end)