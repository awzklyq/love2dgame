FileManager.addAllPath("assert")

-- math.randomseed(os.time()%10000)

local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2

currentCamera3D.eye = Vector3.new( 525.36051214316, 2852.3172223799, 1982.0588684058)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)


local aixs = Aixs.new(0,0,0, 150)
local AixsRotation = RotationMatrixs.MakeFromZ(currentCamera3D.eye)
local IsRenderOri = true
local IsRenderBind = false
app.render(function(dt)
    if IsRenderBind then
        AixsRotation = RotationMatrixs.MakeFromZ(currentCamera3D.eye)
        aixs:SetTransform(AixsRotation)
    end
   
    aixs:draw()
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        AixsRotation:Log('aaaaaaaaaa')

        currentCamera3D.eye:Log('bbbbbbbbbbbbb')
    end
end)

-- local checkb = UI.CheckBox.new( 10, 10, 20, 20, "IsRenderOri" )
-- checkb.IsSelect = IsRenderOri
-- checkb.ChangeEvent = function(Enable)
--     IsRenderOri = Enable
-- end

local checkbind = UI.CheckBox.new( 10, 40, 20, 20, "IsBind" )
checkbind.IsSelect = IsRenderBind
checkbind.ChangeEvent = function(Enable)
    IsRenderBind = Enable
end
