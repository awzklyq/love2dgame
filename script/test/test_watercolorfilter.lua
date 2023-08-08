
local meshquad = _G.MeshQuad.new( RenderSet.screenwidth,  RenderSet.screenheight, LColor.new(255, 255, 255, 255))
meshquad.w = RenderSet.screenwidth
meshquad.h = RenderSet.screenheight

--  local image = ImageEx.new("OriBA.png")
local image = ImageEx.new("yizi.png")
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
    meshquad = _G.MeshQuad.new( w,  h, LColor.new(255, 255, 255, 255))
    meshquad.w = w
    meshquad.h = h
end)


app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        IsRenderOri = not IsRenderOri
    end
end)
