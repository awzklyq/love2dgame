FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)
local mesh3d = Mesh3D.new("SM_RailingStairs_Internal.OBJ")
-- mesh3d:setNormalMap("T_Railing_N.TGA")
currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local QudiXULie = function (e, base)
    local C = base
    local Total = 0
    local Nums = {}
    while(e > C) do
        --C = C * 10
        Nums[#Nums + 1] = e % C

        e = (e - Nums[#Nums]) / base
    end

    Nums[#Nums + 1] = e % C

    local Result = 0
    local Di = 1 / math.pow(base, #Nums)
    for i = #Nums, 1, -1 do
        Result = Result + Di * Nums[i]
        Di = Di * base
    end

    return Result
end

-- 2, 3, 5, 7, 11,
-- 13, 17, 19, 23,
-- 29, 31, 37, 41,
-- 43, 47, 53, 59,
-- 61, 67, 71, 73 
-----Halton序列
local Hammersley = function(dimension, index, numSamples, Prime)
    if dimension == 0 then
        return index / numSamples;
    else
        return QudiXULie(index, Prime);
    end
end

--Hammersley 序列
function MatchRandom4()
    local total = 0
    MatchRects = {}
    local step = 8
    for i= 1, step do
        local xi = Hammersley(0, i, step, 2)
        local yi = Hammersley(1, i, step, 2)
        local zi = Hammersley(1, i, step, 3)
        local V = Vector3.new(xi, yi, zi)
        V:normalize()
        log('Match Hammersley', V.x, V.y, V.z )
    end

end

MatchRandom4()
local imagenames = {'T_Railing_M.TGA', "T_FloorMarble_D.TGA"}

local index = 2
mesh3d:setCanvas(ImageEx.new(imagenames[index]) )

local scene = Scene3D.new()
scene.needSSAO = true
local node = scene:addMesh(mesh3d)

local RenderNormal = false
local RenderDepth = false
app.render(function(dt)
    scene:update(dt)
    scene:draw(true)

    if RenderNormal then
        scene.canvasnormal:draw()
    elseif RenderDepth then
        scene.canvasdepth:draw()
    end
    -- love.graphics.print( "Image name: ".. imagenames[index] .. " SSAO: ".. tostring(scene.needSSAO) .. " SSAOValue: ".. tostring(RenderSet.getSSAOValue()).." SSAODepthLimit: ".. tostring(RenderSet.getSSAODepthLimit()), 10, 10)
end)


local scrollbar1 = UI.ScrollBar.new( 'SSAOValue', 10, 10, 250, 40, 0, 20, 0.1)
scrollbar1.Value = RenderSet.getSSAOValue()
scrollbar1.ChangeEvent = function(v)
    RenderSet.setSSAOValue(v)
end

local scrollbar2 = UI.ScrollBar.new( 'SSAODepthLimit', 10, 60, 250, 40, 0, 0.0001, 0.00001)
scrollbar2.Value = RenderSet.getSSAODepthLimit()
scrollbar2.ChangeEvent = function(v)
    RenderSet.setSSAODepthLimit(v)
end

local checkb = UI.CheckBox.new( 10, 110, 20, 20, "SSAO" )
checkb.IsSelect = true
checkb.ChangeEvent = function(Enable)
    scene.needSSAO = Enable
end

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        currentCamera3D.eye = Vector3.sub(currentCamera3D.eye, currentCamera3D.look)
        currentCamera3D.look = Vector3.new(0,0,0)
    end

    if key == "up" then
        RenderSet.setSSAOValue(RenderSet.getSSAOValue() + 1)
    elseif key == 'down' then
        RenderSet.setSSAOValue(RenderSet.getSSAOValue() - 1)
    end

    if key == "left" then
        RenderSet.setSSAODepthLimit(RenderSet.getSSAODepthLimit() + 0.0001)
    elseif key == 'right' then
        RenderSet.setSSAODepthLimit(math.max(RenderSet.getSSAODepthLimit() - 0.0001, 0))
    end

    if key == 'z' then
        RenderNormal = not RenderNormal
    elseif key == 'x' then
        RenderDepth = not RenderDepth

    end
end)
