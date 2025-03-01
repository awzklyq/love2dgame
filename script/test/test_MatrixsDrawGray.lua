math.randomseed(os.time()%10000)
RenderSet.BGColor = LColor.new(80,80,80,255)

local M = 15
local N = 15
local mat = Matrixs.new(M, N)
for i = 1, mat.Row do
    for j = 1, mat.Column do
        mat:SetValue(i, j, math.random(1, 100) > 50 and 1 or 0)
    end
end

mat:GenerateDrawGrayDatas(50, 50, 500, 500)

app.render(function(dt)
    mat:DrawGrayDatas()
end)