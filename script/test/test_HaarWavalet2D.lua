FileManager.addAllPath("assert")

local _Image = ImageEx.new("qq1.png")

local _Haar = HaarWavalet2D.new(_Image)

-- local TestDatas = {}
-- TestDatas[1] = {8, 4, 2, 6}
-- TestDatas[2] = {3, 5, 7, 1}
-- TestDatas[3] = {9, 1, 3, 5}
-- TestDatas[4] = {2, 8, 4, 6}
-- _Haar:Process(TestDatas, 4, 4, 4, 4)
-- _Haar:InverseProcessInner(TestDatas, 4, 4, 1, 1)
-- for i = 1, #TestDatas do
--     local SSS = ""
--     for j = 1, #TestDatas[i] do
--         SSS = SSS .. tostring(TestDatas[i][j]) .. " "
--     end
--     log(SSS)
-- end

_Haar:InverseProcess()
local _HaarImage = _Haar:GenerateImageData()
local _IsRenderOriImage = true
app.render(function(dt)
    if _IsRenderOriImage then
        _Image:draw()
    else
        _HaarImage:draw()
    end
    
end)

local checkb = UI.CheckBox.new( 10, 10, 20, 20, "RenderOri" )
checkb.IsSelect = _IsRenderOriImage
checkb.ChangeEvent = function(Enable)
    _IsRenderOriImage = Enable
end