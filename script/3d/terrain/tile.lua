_G.__createClassFromLoveObj("Tile3D")

local vertexFormat = {
    {"VertexPosition", "float", 3},
    {"VertexTexCoord", "float", 2},
    {"VertexColor", "float", 3},--normal
    -- {"ConstantColor", "byte", 4},
}

function Tile3D.new(StartPos, EndPos, BlockNum, LodLevel)-- lw :line width
    local tile = setmetatable({}, Tile3D);
    tile.Transform3d = Matrix3D.new();


    tile.StartPos = StartPos
    tile.EndPos = EndPos
    tile.BlockNum = BlockNum > 0  and BlockNum or 2
    tile.LodLevel = LodLevel
    tile.OrigLodVertexs = {}
    tile:CreateVertexLod(tile.StartPos, tile.EndPos, tile.BlockNum, tile.LodLevel)
    tile.Shader = Shader.GetTile3DShader()
    tile.objs = {}
    for i = 1, tile.LodLevel do
        tile.objs[i] = love.graphics.newMesh(vertexFormat, tile.LodVertexs[i], "triangles")
    end
    tile.obj = tile.objs[1]

    tile.CurrentLod = 1

    tile.BColor = LColor.new(255,255,255,255)

    tile.renderid = Render.Tile3DId;

    tile.Visible = true

    tile.RenderType = "normal"

    tile.LT_LOD = 1
    tile.RT_LOD = 1
    tile.RB_LOD = 1
    tile.LB_LOD = 1

    return tile
end

local CopyVertex = function(v)
    local result = Vector3.new(v.x, v.y, v.z)
    result.UV = Vector.new(v.UV.x, v.UV.y)
    result.Normal = Vector3.new(v.Normal.x, v.Normal.y, v.Normal.z)
    result.UserData = v.UserData
    return result
end

Tile3D.TestCo = 0.001;
Tile3D.TestH = 2000;
Tile3D.TestRandom  = 100--math.random(1,100)
function Tile3D:CreateVertexLod(StartPos, EndPos, BlockNum, LodLevel)
    self.LodVertexs = {}
    local Vertrxs = {}
    local EdgeLengthX = (EndPos.x - StartPos.x) / BlockNum
    local EdgeLengthY = (EndPos.y - StartPos.y) / BlockNum
    
    for level = 1, LodLevel do
        if level == 1 then
            local UVs = {}
            local Normals = {}
            local xi = 1
            for ix = StartPos.x, EndPos.x, EdgeLengthX do
                local yi = 1

                Vertrxs[xi] = {}
                for iy = StartPos.y, EndPos.y, EdgeLengthY do
                    -- log(math.noise(ix * Tile3D.TestCo, iy * Tile3D.TestCo, Tile3D.TestRandom))
                    local Vertex = Vector3.new(ix, iy, Tile3D.TestH * math.noise(ix * Tile3D.TestCo, iy * Tile3D.TestCo, Tile3D.TestRandom)) -- test
                    Vertex.UV = Vector.new((ix - StartPos.x) / (EndPos.x - StartPos.x), (iy - StartPos.y) / (EndPos.y - StartPos.y))
                    Vertex.Normal = Vector3.new(0, 0, 1)
                    Vertrxs[xi][yi] = Vertex
                    yi = yi + 1
                end

                xi = xi + 1
            end
        end
        
        --the last one vertex
        -- local Vertex = Vector3.new(StartPos.x + Size, StartPos.y + Size, 0)
        -- Vertex.UV = Vector.new(1, 1)
        -- Vertex.Normal = Vector3.new(0, 0, 1)
        -- Vertrxs[#Vertrxs + 1] = Vertex
        local Faces = {}
        local OrigLodVertexs = {}
        local iix = 1
        local offsetlevel = math.pow(2, level - 1)
        for ix = 1, #Vertrxs, offsetlevel do
            local iiy = 1
            local nextix = math.min(ix + offsetlevel, #Vertrxs)
            for iy = 1, #Vertrxs[ix], offsetlevel do
                local nextiy = math.min(iy + offsetlevel, #Vertrxs[ix])
                local v1 = Vertrxs[ix][iy]
                local v2 = Vertrxs[ix][nextiy]

                local v3 =  Vertrxs[nextix][nextiy]
                local v4 =  Vertrxs[nextix][iy]

                if not OrigLodVertexs[iix] then
                    OrigLodVertexs[iix] = {}
                end
                OrigLodVertexs[iix][iiy] = v1
                OrigLodVertexs[iix][iiy + 1] = v2

                if not OrigLodVertexs[iix + 1] then
                    OrigLodVertexs[iix + 1] = {}
                end
                OrigLodVertexs[iix + 1][iiy + 1] = v3
                OrigLodVertexs[iix + 1][iiy]  = v4
                Faces[#Faces + 1] = {v1, v2, v3}
                Faces[#Faces + 1] = {v1, v3, v4}

                iiy = iiy + 1
            end
            iix = iix + 1
            OrigLodVertexs[#OrigLodVertexs + 1] = OrigLodVertex
        end

        local LodVertexs = {}

        -- Compute normal..
        for i = 1, #Faces do
            local Face  = Faces[i]
            local v1 = Vector3.new(Face[1].x - Face[2].x, Face[1].y - Face[2].y, Face[1].z - Face[2].z)
            local v2 = Vector3.new(Face[1].x - Face[3].x, Face[1].y - Face[3].y, Face[1].z - Face[3].z)
            local cross = Vector3.cross(v1, v2)
            cross:normalize()

            for fi = 1, 3 do
                Face[fi].Normal.x = Face[fi].Normal.x + cross.x
                Face[fi].Normal.y = Face[fi].Normal.y + cross.y
                Face[fi].Normal.z = Face[fi].Normal.z + cross.z
                Face[fi].Normal:normalize()
            end
        end

        for i = 1, #Faces do
            local Face  = Faces[i]
            for fi = 1, 3 do
                LodVertexs[#LodVertexs + 1] = {Face[fi].x, Face[fi].y, Face[fi].z, Face[fi].UV.x, Face[fi].UV.y, Face[fi].Normal.x, Face[fi].Normal.y, Face[fi].Normal.z }
            end
            
        end
        self.LodVertexs[level] = LodVertexs

        self.OrigLodVertexs[level] = OrigLodVertexs
        self.LodLevel = level
    end --LodLevel
end

function Tile3D:ChangeLod(LodLevel)
    if LodLevel <= self.LodLevel then
        self.Old_LodLevel = self.CurrentLod
        self.CurrentLod = LodLevel
        self.obj = self.objs[self.CurrentLod]
    end
end

function Tile3D:SetBaseColor(color)
    self.BColor = color or self.BColor;
    if self.shader then
        self.shader:setBaseColor(self.BColor)
    end
end

function Tile3D:UseLights()
    self.shader = Shader.GetTile3DShader();

    self.shader:setBaseColor(self.BColor)


    if self.RenderType == 'depth' then
        self.shader = Shader.GeDepth3DShader()
        return
    end

    if self.Nolight then
        return
    end

    if self.RenderType ~=  "normal" then
        return
    end
    local directionlights = _G.Lights.getDirectionLights()

    if #directionlights == 0 then
        return
    end

    for i = 1, #directionlights do
        local light = directionlights[i]
        if self.shader:hasUniform( "directionlight"..i) then
            self.shader:send("directionlight"..i, {light.dir.x, light.dir.y, light.dir.z, 1})
        end
        if self.shader:hasUniform( "directionlightcolor"..i) then
            self.shader:send("directionlightcolor"..i, {light.color._r, light.color._g, light.color._b, light.color._a})
        end
        self.shader:setShadowParam()
    end
end

function Tile3D:draw()
    if not self.Visible then return end
    local camera3d = _G.getGlobalCamera3D()
    --modelMatrix, projectionMatrix, viewMatrix

    -- RenderSet.setNormalMap(self.NormalMap)
    self:UseLights()
    self.shader:setCameraAndMatrix3D(self.Transform3d, RenderSet.getUseProjectMatrix(), RenderSet.getUseViewMatrix(), camera3d.eye)

    if self.shader:hasUniform( "bcolor") and self.BColor then
        self.shader:send('bcolor',{self.BColor._r, self.BColor._g, self.BColor._b, self.BColor._a})
    end
    Render.RenderObject(self)
    -- RenderSet.setNormalMap()
end

function Tile3D:IsNeedCDLOD()
    if self.Old_LodLevel == self.CurrentLod and self.Old_L_LOD == self.L_LOD and self.R_LOD == self.Old_R_LOD and self.B_LOD == self.Old_B_LOD and  self.T_LOD == self.Old_T_LOD then
        return false
    end
    if self.CurrentLod < self.L_LOD or self.CurrentLod < self.R_LOD or self.CurrentLod < self.T_LOD or self.CurrentLod < self.B_LOD then
        return true
    end

    return false
end

function Tile3D:SelectLod()
    local camera3d = _G.getGlobalCamera3D()

    local eye = camera3d.eye

    local TileCenter = (self.EndPos + self.StartPos) * 0.5 
    local Distance = Vector3.distance(eye, TileCenter)
    -- log(Distance, self.StartPos.x, self.StartPos.y)
    
    if Distance <= RenderSet.LOD1Distance then
        -- log('aaaaaaa')
        self:ChangeLod(1)
        -- self:SetBaseColor(LColor.new(255,255,255))
    elseif Distance <= RenderSet.LOD2Distance and self.LodLevel >= 2 then
        -- log('bbbbbbb')
        self:ChangeLod(2)
        -- self:SetBaseColor(LColor.new(255,50,50))
    elseif Distance <= RenderSet.LOD3Distance and self.LodLevel >= 3 then
        self:ChangeLod(3)
        -- self:SetBaseColor(LColor.new(50,255,50))
    else
        self:ChangeLod(self.LodLevel)
        -- self:SetBaseColor(LColor.new(50,255,50))
    end
end

function Tile3D:UpdateForLOD(dt)
    -- if self.CurrentLod == self.LodLevel then
    --     return
    -- end
    
    TileCached.GetAroundLODCached(self)

    if not self:IsNeedCDLOD() then return end

    local Vertexs = {}
    local Faces = {}

    local OrigLodVertexs = {}
    local TempOrigLodVertexs = self.OrigLodVertexs[self.CurrentLod]


    for ix = 1, #TempOrigLodVertexs do
        local TempOrigLodVertex = TempOrigLodVertexs[ix]
        local OrigLodVertex = {}
        for iy = 1, #TempOrigLodVertexs[ix] do
            OrigLodVertex[iy] = CopyVertex(TempOrigLodVertexs[ix][iy])
           
            if RenderSet.EnableCDLOD then
                if self.CurrentLod < self.T_LOD or self.CurrentLod < self.B_LOD then --or self.CurrentLod < self.B_LOD
                    if ix % 2 == 0 and ix > 1 and ix < #TempOrigLodVertexs then
                        local lerp = (iy -1) / (#TempOrigLodVertexs - 1)

                        if self.CurrentLod < self.B_LOD and iy >= #TempOrigLodVertexs[ix] * 0.5 then  
                            local lerp = math.clamp((iy -#TempOrigLodVertexs[ix] * 0.5) / (#TempOrigLodVertexs - 1 - #TempOrigLodVertexs[ix] * 0.5), 0, 1)
                            OrigLodVertex[iy].x = math.lerp (OrigLodVertex[iy].x, TempOrigLodVertexs[ix + 1][iy].x, lerp)
                            OrigLodVertex[iy].z = Tile3D.TestH * math.noise(OrigLodVertex[iy].x * Tile3D.TestCo, OrigLodVertex[iy].y * Tile3D.TestCo, Tile3D.TestRandom)

                            OrigLodVertex[iy].Normal =  Vector3.lerp(OrigLodVertex[iy].Normal, TempOrigLodVertexs[ix + 1][iy].Normal, lerp)
                        end

                        if self.CurrentLod < self.T_LOD and iy < #TempOrigLodVertexs[ix] * 0.5 then   
                            local lerp = math.clamp((iy -1) / (#TempOrigLodVertexs[ix] * 0.5),0,1)
                            OrigLodVertex[iy].x = math.lerp (OrigLodVertex[iy].x, TempOrigLodVertexs[ix + 1][iy].x, 1 - lerp)
                            OrigLodVertex[iy].z = Tile3D.TestH * math.noise(OrigLodVertex[iy].x * Tile3D.TestCo, OrigLodVertex[iy].y * Tile3D.TestCo, Tile3D.TestRandom)

                            OrigLodVertex[iy].Normal = Vector3.lerp (OrigLodVertex[iy].Normal, TempOrigLodVertexs[ix + 1][iy].Normal, 1 - lerp)
                        end
                    end
                end

                if self.CurrentLod < self.R_LOD or self.CurrentLod < self.L_LOD then --or self.CurrentLod < self.R_LOD
                    if iy % 2 == 0 and iy > 1 and iy < #TempOrigLodVertexs[ix] then
                        local lerp =  (ix - 1) / (#TempOrigLodVertexs[ix] - 1)
                        if self.CurrentLod < self.R_LOD and ix >= #TempOrigLodVertexs * 0.5 then
                            local lerp =  math.clamp((ix - #TempOrigLodVertexs * 0.5) / (#TempOrigLodVertexs * 0.5), 0, 1)
                            OrigLodVertex[iy].y = math.lerp (OrigLodVertex[iy].y, TempOrigLodVertexs[ix][iy + 1].y, lerp)
                            OrigLodVertex[iy].z = Tile3D.TestH * math.noise(OrigLodVertex[iy].x * Tile3D.TestCo, OrigLodVertex[iy].y * Tile3D.TestCo, Tile3D.TestRandom)

                            OrigLodVertex[iy].Normal = Vector3.lerp (OrigLodVertex[iy].Normal, TempOrigLodVertexs[ix][iy + 1].Normal, lerp)
                        end

                        if self.CurrentLod < self.L_LOD and ix < #TempOrigLodVertexs * 0.5 then
                            local lerp =  math.clamp((ix - 1) / (#TempOrigLodVertexs * 0.5), 0, 1)
                            OrigLodVertex[iy].y = math.lerp (OrigLodVertex[iy].y, TempOrigLodVertexs[ix][iy + 1].y, 1 - lerp)
                            OrigLodVertex[iy].z = Tile3D.TestH * math.noise(OrigLodVertex[iy].x * Tile3D.TestCo, OrigLodVertex[iy].y * Tile3D.TestCo, Tile3D.TestRandom)

                            OrigLodVertex[iy].Normal = Vector3.lerp (OrigLodVertex[iy].Normal, TempOrigLodVertexs[ix][iy + 1].Normal, 1 - lerp)
                        end
                    end 
                end
            end
           
        end

        OrigLodVertexs[ix] = OrigLodVertex
     end

    for ix = 1, #OrigLodVertexs -1 do
        local OrigLodVertex = OrigLodVertexs[ix]
        for iy = 1, #OrigLodVertex -1 do
            local v1 = OrigLodVertexs[ix][iy]
            local v2 = OrigLodVertexs[ix][iy + 1]
            local v3 = OrigLodVertexs[ix + 1][iy + 1]
            local v4 = OrigLodVertexs[ix + 1][iy]

            Faces[#Faces + 1] = {v1, v2, v3}
            Faces[#Faces + 1] = {v1, v3, v4}
        end
    end
   
    local LodVertexs = {}
    for i = 1, #Faces do
        local Face  = Faces[i]
        for fi = 1, 3 do
            LodVertexs[#LodVertexs + 1] = {Face[fi].x, Face[fi].y, Face[fi].z, Face[fi].UV.x, Face[fi].UV.y, Face[fi].Normal.x, Face[fi].Normal.y, Face[fi].Normal.z }  
        end
        
    end

    self.objs[self.CurrentLod] = love.graphics.newMesh(vertexFormat, LodVertexs, "triangles")
    self:ChangeLod(self.CurrentLod)
end

_G.TileCached = {}

TileCached.Tiles = {}


TileCached.SetBoundSize = function(x1, y1, x2, y2, TileSizeX, TileSizeY)
    TileCached.Min = Vector.new(x1, y1)
    TileCached.Max = Vector.new(x2, y2)
    TileCached.TileSizeX = TileSizeX
    TileCached.TileSizeY = TileSizeY

    TileCached.XN = 0
    TileCached.YN = 0
end

TileCached.AddCached = function(tile)
    local center = (tile.EndPos + tile.StartPos) * 0.5
    local ix = math.ceil((center.x - TileCached.Min.x) / TileCached.TileSizeX)
    local iy = math.ceil((center.y - TileCached.Min.y) / TileCached.TileSizeY)

    if not TileCached.Tiles[ix] then
        TileCached.Tiles[ix] = {}
    end
    TileCached.Tiles[ix][iy] = tile

    TileCached.XN = math.max(TileCached.XN, ix)
    TileCached.YN = math.max(TileCached.YN, iy)
end

TileCached.GetAroundLODCached = function(tile)
    local center = (tile.EndPos + tile.StartPos) * 0.5
    local ix = math.ceil((center.x - TileCached.Min.x) / TileCached.TileSizeX)
    local iy = math.ceil((center.y - TileCached.Min.y) / TileCached.TileSizeY)

    tile.Old_L_LOD = tile.L_LOD;
    tile.Old_R_LOD = tile.R_LOD;
    tile.Old_T_LOD = tile.T_LOD;
    tile.Old_B_LOD = tile.B_LOD;

    tile.L_LOD = 1
    tile.R_LOD = 1
    tile.T_LOD = 1
    tile.B_LOD = 1

    if ix > 1 then
        tile.L_LOD = TileCached.Tiles[ix - 1][iy].CurrentLod
    end

    if ix < TileCached.XN then
        tile.R_LOD = TileCached.Tiles[ix + 1][iy].CurrentLod
    end

    if iy > 1 then
        tile.T_LOD = TileCached.Tiles[ix][iy - 1].CurrentLod
        -- log('ccccccc', tile.T_LOD)
    end

    if iy < TileCached.YN then
        tile.B_LOD = TileCached.Tiles[ix][iy + 1].CurrentLod
        -- log('dddddddddd', tile.B_LOD)
    end

    -- TileCached.Tiles[4][3].Visible = false
    -- if ix == 3 and iy == 3 then
    --     log( #TileCached, 'L_LOD', tile.L_LOD ,'R_LOD', tile.R_LOD, 'T_LOD', tile.T_LOD, 'B_LOD', tile.B_LOD )
    -- end

end
