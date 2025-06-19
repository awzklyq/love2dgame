local TestStruct = {}
TestStruct.a = {}
TestStruct.a.name = "A_Name"
TestStruct.a.Age = 12

TestStruct.b = {}
TestStruct.b.name = "B_Name"
TestStruct.b.Age = 18

local function Traverse (InTable)
    coroutine.yield(InTable)
    if type(InTable) == 'table' then
        for i, v in pairs(InTable) do
            Traverse(InTable[i])
        end
    end
end

local Next_Test = function (InTable)
    return coroutine.wrap(function ()
        Traverse(InTable)
    end)
end

log('aaaaa', TestStruct)
for n in Next_Test(TestStruct) do
    log(n)
end
