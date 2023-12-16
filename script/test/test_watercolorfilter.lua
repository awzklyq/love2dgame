
-- local meshquad = _G.MeshQuad.new( RenderSet.screenwidth,  RenderSet.screenheight, LColor.new(255, 255, 255, 255))
-- meshquad.w = RenderSet.screenwidth
-- meshquad.h = RenderSet.screenheight

--  local image = ImageEx.new("OriBA.png")
-- local image = ImageEx.new("yizi.png")
local image = ImageEx.new("itgongzuo.jpg")

image.renderWidth = RenderSet.screenwidth
image.renderHeight = RenderSet.screenheight
--local image = ImageEx.new("xing.png")
app.update(function(dt)
   
end)

local IsRenderOri = false
app.render(function(dt)
    --image:draw()
    if IsRenderOri then
        image:draw()
    else
        local RenderCanvan = WaterColorFilterNode.Execute(image) 
        RenderCanvan:draw()
    end

end)

app.resizeWindow(function(w, h)
    -- meshquad = _G.MeshQuad.new( w,  h, LColor.new(255, 255, 255, 255))
    -- meshquad.w = w
    -- meshquad.h = h
    image.renderWidth = RenderSet.screenwidth
    image.renderHeight = RenderSet.screenheight
end)


app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        IsRenderOri = not IsRenderOri
    end
end)

local checkb = UI.CheckBox.new( 10, 10, 20, 20, "IsRenderOri" )
checkb.IsSelect = IsRenderOri
checkb.ChangeEvent = function(Enable)
    IsRenderOri = Enable
end


local checkb = UI.CheckBox.new( 10, 30, 20, 20, "Open:Type 1, Closed:Type 2" )
checkb.IsSelect = WaterColorFilterNode.Type == 1 
checkb.ChangeEvent = function(Enable)
    if Enable then
        WaterColorFilterNode.Type = 1
    else
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

