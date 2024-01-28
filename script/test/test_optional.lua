local testnum = Optional.new('number')
testnum(10)
log("Optional A", testnum)

local testbool = Optional.new(false)
log("Optional B", testbool, testbool:HasValue())
testbool:CheckValue()