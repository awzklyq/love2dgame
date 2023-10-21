
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