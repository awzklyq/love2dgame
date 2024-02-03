local MFD = MathFunctionDisplay.new(RenderSet.screenwidth, RenderSet.screenheight)


MFD:GeneratePoints1(1, 100, 2, LColor.new(255,255,0,255), function(x)
    local y = x * 3
    return y
end)

MFD:GeneratePoints2(1, 100, 2, LColor.new(0,255,0,255), function(x)
    local y = x * x
    return y
end)

app.render(function(dt)
 
    MFD:draw()

end)

app.resizeWindow(function(w, h)
    MFD:ResetWH(w, h)
end)

local scrollbarX = UI.ScrollBar.new( 'S X', 10, 10, 200, 40, 1, 20, 0.5)
scrollbarX.Value = MFD.ScaleX
scrollbarX.ChangeEvent = function(v)
    MFD:SetScale(scrollbarX.Value, MFD.ScaleY)
end

local scrollbarY = UI.ScrollBar.new( 'S Y', 10, 50, 200, 40, 0.05, 2, 0.05)
scrollbarY.Value = MFD.ScaleY
scrollbarY.ChangeEvent = function(v)
    MFD:SetScale(MFD.ScaleX, scrollbarY.Value)
end