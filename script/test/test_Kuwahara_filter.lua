FileManager.addAllPath("assert")

local cb = UI.ComboBox.new(10, 10, 100, 40, {"Default", "Blur", "Kuwahara"})
cb.Value = "Default"
local RenderType = "Default"
cb.ChangeEvent = function(value)
    RenderType = value
end


local testnoise = ImageEx.new('testnoise.png')



app.render(function(dt)
    if RenderType == "Default" then
        testnoise:draw()
    elseif RenderType == "Blur" then
        local testBlur = BlurFilterNode.Execute(testnoise)
        testBlur:draw()
    elseif RenderType == "Kuwahara" then
        local testKuwahara = KuwaharaFilterNode.Execute(testnoise)
        testKuwahara:draw()
    end
end)
