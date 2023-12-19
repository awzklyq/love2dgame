local image = ImageEx.new("itgongzuo.jpg")

image.renderWidth = RenderSet.screenwidth
image.renderHeight = RenderSet.screenheight

local IsRenderOri = true
app.render(function(dt)
    if IsRenderOri then
        image:draw()
    else
        local RenderCanvan = WaterColorFilterNode.Execute(image) 
        RenderCanvan:draw()
    end

end)

app.resizeWindow(function(w, h)
    image.renderWidth = RenderSet.screenwidth
    image.renderHeight = RenderSet.screenheight
end)


app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        IsRenderOri = not IsRenderOri
    end
end)

local cb = UI.ComboBox.new(10, 10, 120, 35, {"RenderOri", "OpenType1", "OpenType2"})
cb.Value = "RenderOri"
cb.ChangeEvent = function(value)
    if value == "RenderOri" then
        IsRenderOri = true
    elseif value == "OpenType1" then
        WaterColorFilterNode.Type = 1
        IsRenderOri = false
    elseif value == "OpenType2" then
        IsRenderOri = false
        WaterColorFilterNode.Type = 2
    end

end

local scrollbar1 = UI.ScrollBar.new( 'Offset', 10, 60, 200, 40, 0.1, 10, 0.1)
scrollbar1.Value = WaterColorFilterNode.Offset
scrollbar1.ChangeEvent = function(v)
    WaterColorFilterNode.Offset = v
end

local scrollbar2 = UI.ScrollBar.new( 'Scale1', 10, 100, 200, 40, 0.01, 1, 0.01)
scrollbar2.Value = WaterColorFilterNode.Scale1
scrollbar2.ChangeEvent = function(v)
    WaterColorFilterNode.Scale1 = v
end


local scrollbar3 = UI.ScrollBar.new( 'Scale2', 10, 140, 200, 40, 0.01, 1, 0.01)
scrollbar3.Value = WaterColorFilterNode.Scale2
scrollbar3.ChangeEvent = function(v)
    WaterColorFilterNode.Scale2 = v
end

