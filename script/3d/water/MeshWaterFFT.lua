local vertexFormat = {
    {"VertexPosition", "float", 3},
    {"VertexTexCoord", "float", 2},
    {"VertexColor", "float", 3},--normal
    {"ConstantColor", "float", 4},
    {"ConstantColor2", "float", 2},
}

-- Use Phillips
_G.MeshWaterFFT = {}
MeshWaterFFT._Meta = {__index = MeshWaterFFT}

function MeshWaterFFT.new(InX, InY, InSize)
    local _mw = setmetatable({}, MeshWaterFFT._Meta)

    _mw._X = InX
    _mw._Y = InY
    _mw._Size = InSize
    _mw.transform3d = Matrix3D.new()

    _mw.renderid = Render.MeshWaterFFTId

    _mw._Mesh = _mw:CreatWaterPlane(InX, InY, InSize, 0)
    return _mw
end

function MeshWaterFFT:CreatWaterPlane(InX, InY, InSize)
    local X = InX * InSize
    local Y = InY * InSize
    local HalfX = X * 0.5
    local HalfY = Y * 0.5

    local H = InH or 0

    local Datas = {}
    for _x = -HalfX, HalfX, InSize do
        local I = #Datas + 1
        Datas[I] = {}
        for _y = -HalfY, HalfY, InSize do
            local _Pos = Vector3.new(_x, _y, H) 
            local _Nor = Vector3.new(0, 0, 1)
            local _UV = Vector.new((_x + HalfX) / X, (_y + HalfY) / Y)
            Datas[I][#Datas[I] + 1] = {_Pos.x, _Pos.y, _Pos.z, _UV.x, _UV.y, _Nor.x, _Nor.y, _Nor.z}
        end
    end

    local Verts = {}
    for i = 1, #Datas - 1 do
        for j = 1, #Datas[1] - 1 do
            Verts[#Verts + 1] = Datas[i][j]
             Verts[#Verts + 1] = Datas[i + 1][j + 1] 
            Verts[#Verts + 1] = Datas[i + 1][j]

            Verts[#Verts + 1] = Datas[i][j]
            Verts[#Verts + 1] = Datas[i][j + 1] 
            Verts[#Verts + 1] = Datas[i + 1][j + 1]
            
        end
    end

    self.obj = love.graphics.newMesh(vertexFormat, Verts, "triangles")
end


function MeshWaterFFT:UseLights()
    if self.nolight then
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
    end
end


function MeshWaterFFT:SetWaterMap(InFileName)
    self._WaterMap = ImageEx.new(InFileName)
end

function MeshWaterFFT:draw()
    -- self._Mesh:draw()
    self.shader = Shader.GetWaterFFTShader();

    local camera3d = _G.getGlobalCamera3D()
    --modelMatrix, projectionMatrix, viewMatrix

    -- RenderSet.setNormalMap(self.normalmap)
    self:UseLights()
    self.shader:setCameraAndMatrix3D(self.transform3d, RenderSet.getUseProjectMatrix(), RenderSet.getUseViewMatrix(), camera3d.eye)

    self.shader:setWaterValue(self._WaterMap and self._WaterMap.obj or nil)

    if self.shader:hasUniform( "bcolor") and self.bcolor then
        self.shader:send('bcolor',{self.bcolor._r, self.bcolor._g, self.bcolor._b, self.bcolor._a})
    end

    -- love.graphics.setMeshCullMode("none")
    -- love.graphics.setDepthMode("less", true)

    Render.RenderObject(self)
end