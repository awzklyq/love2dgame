

FileManager.addAllPath("assert")

local btn = UI.Button.new( 10, 10, 100, 50, 'Play', 'btn' )

btn.x = 50

btn:setPressedColor(LColor.new(125, 125, 125))

local shengyin = Audio.new("3.wav")
btn.ClickEvent = function()
    shengyin:rePlay()
end

local scrollbar = UI.ScrollBar.new( 'Volume', 10, 60, 200, 40, 0.1, 5, 0.1)
scrollbar.Value = shengyin:getVolume()
scrollbar.ChangeEvent = function(v)
    shengyin:setVolume(v)
end

local scrollbar2 = UI.ScrollBar.new( 'Velocity', 10, 100, 200, 40, 0.1, 5, 0.1)
-- scrollbar2.Value = shengyin:getVelocity()
scrollbar2.ChangeEvent = function(v)
    shengyin:setVelocity(1,1)
end