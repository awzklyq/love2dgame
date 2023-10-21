
local btn = UI.Button.new( 10, 10, 100, 50, 'test', 'btn' )

btn.x = 50

btn:setPressedColor(LColor.new(125, 125, 125))

local text = UI.Text.new( "sdfertre", 100, 50, 60, 50 )
text:SetNormalColor(255, 0, 0, 255)

btn.click = function()
    text:SetNormalColor(0, 0, 255, 255)

    text.text = "Test AAA"
end

-- local text = love.graphics.newText( love.graphics.getFont(), "asdasdawarewre" )

-- app.render(function(dt)
--     love.graphics.draw(text, 200, 200, 0, 1, 1 )
-- end)

local TestRect = Rect.new(200, 200, 50, 50)

TestRect:SetMouseEventEable(true)
TestRect.MouseDownEvent = function(SelectElement, x, y, button, istouch)
    log('test Rect')
end

local TestCircle = Circle.new(50, 200 ,300, 50)
TestCircle:SetMouseEventEable(true)
TestCircle.MouseDownEvent = function(SelectElement, x, y, button, istouch)
    log('test Circle')
end

app.render(function(dt)

    TestRect:draw()

    TestCircle:draw()
end)