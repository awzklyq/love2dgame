FileManager.addAllPath("assert")

-- local font = Font.new"minijtls.TTF"
-- font:Use()

-- math.randomseed(os.time()%10000)
-- love.graphics.setWireframe( true )
local aixs = Aixs.new(0,0,0, 150)
local IsUseLight = false

local QTree = QuadTree.new()
local TileAlts = {}
local CallBackFunc = function(QNode)
    TileAlts[#TileAlts + 1] = Tile3D.new(QNode.Box.min, QNode.Box.max,  16, 3)
    QNode.Tile = TileAlts[#TileAlts]
    TileCached.AddCached(QNode.Tile)

    QNode.Tile:SetBaseColor(LColor.new(math.random(20,180),math.random(20,200),math.random(20,100)))
end

local QSize = 3200
local TileSize = 800
TileCached.SetBoundSize(-QSize * 0.5, -QSize * 0.5, QSize * 0.5, QSize * 0.5, TileSize, TileSize)
QTree:CreateOctreesNode(TileSize, QSize, CallBackFunc)

local QFrustum = Frustum.new()

local DebugLine = {}
local VisibleTiles = {}
app.render(function(dt)
    love.graphics.clear(0,0,0,1)
    aixs:draw()
    
    QFrustum:buildFromViewAndProject(RenderSet.getCameraFrustumViewMatrix(), RenderSet.getCameraFrustumProjectMatrix())

    VisibleTiles = {}
    QTree:Update(dt, QFrustum, VisibleTiles)

    for i = 1, #VisibleTiles do
        VisibleTiles[i]:SelectLod()
    end
    for i = 1, #VisibleTiles do
        VisibleTiles[i]:UpdateForLOD()
        VisibleTiles[i]:draw()
    end
end)

local mat = Matrix3D.new()
mat:mulTranslationLeft(1, 436, 208)
mat:mulRotationLeft(0, 0, 1, 20)
currentCamera3D.eye = mat:getTranslation()
app.update(function(dt)

    -- currentCamera3D:moveTheta(dt)
end)

app.keypressed(function(key, scancode)
    if key == "w" then
        log(currentCamera3D.eye.x,currentCamera3D.eye.y,currentCamera3D.eye.z)
        log(currentCamera3D.look.x,currentCamera3D.look.y,currentCamera3D.look.z)
    elseif key == 'a' then
        love.graphics.setWireframe( true )
    elseif key == 'z' then
        love.graphics.setWireframe( false )
    elseif key == "x" then
        RenderSet.EnableCDLOD = not RenderSet.EnableCDLOD
    elseif key == "space" then
        IsUseLight = not IsUseLight
        if IsUseLight then
            local currentCamera3D = getGlobalCamera3D()
            local directionlight = DirectionLight.new((currentCamera3D.eye - currentCamera3D.look):normalize(), LColor.new(255,255,255,255))
            _G.useLight(directionlight)
        else
            _G.popLight()
        end
    end
end)

currentCamera3D.eye = Vector3.new( -20, -372, 189)
currentCamera3D.look = Vector3.new( 0, 0, 0)