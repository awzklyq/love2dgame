
FileManager.addAllPath("assert")

math.randomseed(os.time()%10000)
-- love.graphics.setWireframe( true )
local aixs = Aixs.new(0,0,0, 500)
local directionlight = DirectionLight.new((currentCamera3D.eye - currentCamera3D.look):normalize(), LColor.new(255,255,255,255))
_G.useLight(directionlight)

local _Water = MeshWaterFFT.new(20, 20, 40)

_Water:SetWaterMap('water.jpg')
app.render(function(dt)
    RenderSet.UseCanvasColorAndDepth()

    aixs:draw()
    _Water:draw()

    RenderSet.ClearCanvasColorAndDepth()
    RenderSet.getCanvasColor():draw()
end)

app.update(function(dt)
    _Water:update(dt)
end)

currentCamera3D.eye = Vector3.new( 195.88320929841 ,281.50478660121 ,206.73155244685)
currentCamera3D.look = Vector3.new(0, 0 ,0)


--Test
-- local TestC = Complex.new(math.random(-1000, 1000), math.random(-1000, 1000))
-- local TestCon = TestC:Conjugate()

-- for i = 1, 10 do
--     local _Angle = math.random(-20, 20)
--     local TestAngleC = Complex.CreateFromAngle(_Angle)
--     local TestAngleCon = Complex.CreateFromAngle(-_Angle)
    
--     TestC = TestC * TestAngleC
--     TestCon = TestCon * TestAngleCon
--     local _Test = TestC + TestCon
--     log('aaaaaaaa', i, TestC:GetReal(), TestC:GetImag(), TestCon:GetReal(), TestCon:GetImag(), _Test:GetReal(), _Test:GetImag())
-- end
