
local VE = MovedEntity.new()

-- VE:AddTimeAndVelocity(2, 4)
-- VE:AddTimeAndVelocity(4, 2)
-- VE:AddTimeAndVelocity(6, 1)
-- VE:AddTimeAndVelocity(10, 5)

local Scale = 1

VE:AddTimeAndDistance(  0       ,       0       )
VE:AddTimeAndDistance(  0.22213521126761        ,       498.51858037578 * Scale )
VE:AddTimeAndDistance(  0.24239049295775        ,       536.848434238  * Scale )
VE:AddTimeAndDistance(  0.50638204225352        ,       958.24634655532 * Scale)
VE:AddTimeAndDistance(  0.53012535211268        ,       990.14947807933 * Scale)
VE:AddTimeAndDistance(  0.83597323943662        ,       1334.4267223382 * Scale)
VE:AddTimeAndDistance(  0.86320457746479        ,       1359.903131524  * Scale)
VE:AddTimeAndDistance(  1.1804577464789 ,       1607.51565762   * Scale)
VE:AddTimeAndDistance(  1.5036496478873 ,       1789.8956158664 * Scale)
VE:AddTimeAndDistance(  1.5328732394366 ,       1801.5866388309 * Scale)
VE:AddTimeAndDistance(  1.8954665492958 ,       1908.1419624217 * Scale)
VE:AddTimeAndDistance(  1.9321690140845 ,       1915.8246346555 * Scale)
VE:AddTimeAndDistance(  2.4212112676056 ,       1981.9624217119 * Scale)
VE:AddTimeAndDistance(  2.4660158450704 ,       1985.3027139875 * Scale)
VE:AddTimeAndDistance(  3       ,       2000    )

VE:Log('VE')

local RectType = {}

RectType[1] = {Type = 1, Color = LColor.new(255,255,0,255)}
RectType[2] = {Type = 2, Color = LColor.new(255,0,255,255)}
RectType[3] = {Type = 3, Color = LColor.new(0,255,125,255)}
RectType[4] = {Type = 4, Color = LColor.new(125, 125, 255,255)}
RectType[5] = {Type = 5, Color = LColor.new(125, 88, 200,255)}
return {VE = VE, RectType = RectType}