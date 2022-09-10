FileManager.addAllPath("assert")
mainFont = love.graphics.newFont(_G.FileManager.findFile"minijtls.ttf", 20)
love.graphics.setFont(mainFont)
local TempStr = {}
TempStr["Hello"] = "nihao"
TempStr["World"] = "shijie"

local TempNum = {}
TempNum["Hello"] = "123"
TempNum["World"] = "456"

local StringFormat = function(a, b)
    local str1 = a
    if b then
        str1 = str1 .. b
        str1 = str1 .. "*"..TempStr[b] .. "*"..TempNum[b]
    end
    str1 = str1 .. "*"..TempStr[a] .. "*"..TempNum[a]
    return str1
end

function StringSplit(str, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function (c) fields[#fields + 1] = c end)
    return fields
end

local TestSplit = function(a, str)
    local rs = StringSplit(str, "*")
    if #rs % 3 == 0 then
        log("result is : ",str)
    else
        local str1 = a .. "*" .. rs [4] .. "*"..rs[5]
        log(str1)

        local str2 = string.gsub(rs [1],a,"") .. "*" .. rs [2] .. "*"..rs[3]
        log(str2)
    end

end

local a = "Hello"
local str =StringFormat(a, "World")
log(str)
TestSplit(a, str)
