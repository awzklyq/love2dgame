local line = Line.new(0,0, 800, 400, 1)
RenderSet.ResetCanvasColor(30,10)

RenderSet.getCanvasColor().renderWidth = RenderSet.screenwidth 
RenderSet.getCanvasColor().renderHeight = RenderSet.screenheight

local ps = line:GeneratePoints()
ps:SetColor(255,0,0,255)

local IsRenderPoints = false
local checkb = UI.CheckBox.new( 10, 10, 20, 20, "IsRenderPoints" )
checkb.IsSelect = IsRenderPoints
checkb.ChangeEvent = function(Enable)
    IsRenderPoints = Enable
end

local IsUseRT = true
local checkb2 = UI.CheckBox.new( 10, 40, 20, 20, "IsUseRT" )
checkb2.IsSelect = IsUseRT
checkb2.ChangeEvent = function(Enable)
    IsUseRT = Enable
end

app.render(function(dt)
    if IsUseRT then
        RenderSet.UseCanvasColorAndDepth()
        if IsRenderPoints then
            ps:draw()
        end
        line:draw()
        RenderSet.ClearCanvasColorAndDepth()
        RenderSet.getCanvasColor():draw()
    else
        line:draw()
        if IsRenderPoints then
            ps:draw()
        end
        
    end

    
end)


app.resizeWindow(function(w, h)
    RenderSet.getCanvasColor().renderWidth = w
    RenderSet.getCanvasColor().renderHeight = h
end)