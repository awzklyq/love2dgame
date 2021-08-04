_G.__createClassFromLoveObj("Mesh3D")

local vertexFormat = {
    {"VertexPosition", "float", 3},
    {"VertexTexCoord", "float", 2},
    {"VertexColor", "float", 3},--normal
    {"ConstantColor", "byte", 4},
}

function Mesh3D.new(file)-- lw :line width
    local mesh = setmetatable({}, Mesh3D);
    mesh.transform3d = Matrix3D.new();

    mesh.verts = Mesh3D.loadObjFile(_G.FileManager.findFile(file))
    mesh.shader = Shader.GetBase3DShader()
    mesh:makeNormals()
    mesh.obj = love.graphics.newMesh(vertexFormat, mesh.verts, "triangles")

    mesh.bcolor = LColor.new(255,255,255,255)
    mesh.renderid = Render.Mesh3DId;

    mesh.rendertype = "normal"

    mesh.nolight = false

    mesh.visible = true

    mesh:setRenderType("normal")
    return mesh;
end

function Mesh3D:setCanvas(canvas)
    self:setTexture(canvas.obj)
end

function Mesh3D:setNormalMap(image)
    if not image then
        self.normalmap = nil
        return
    end

    if type(image) == "string" then
        self.normalmap = ImageEx.new(image)
    elseif image.renderid == Render.ImageId then
        self.normalmap = image
    end
end

function Mesh3D:setRenderType(typename)
    self.rendertype = typename or "normal"
    if typename == "normal" then
        self.shader = Shader.GetBase3DShader();
    elseif typename == "normalmap" then
        self.shader = Shader.GeNormal3DShader()
    elseif typename == "depth" then
        self.shader = Shader.GeDepth3DShader()
    else
        self.shader = Shader.GetBase3DShader();
    end
end

function Mesh3D:getRenderType()
    return self.rendertype
end

--{x,y,z,u,v,nx,ny,nz}
function Mesh3D.createFromPoints(datas)
    local mesh = setmetatable({}, Mesh3D);
    mesh.transform3d = Matrix3D.new();

    mesh.verts = datas
    mesh.shader = Shader.GetBase3DShader()
    mesh.obj = love.graphics.newMesh(vertexFormat, mesh.verts, "triangles")

    mesh.renderid = Render.Mesh3DId;

    mesh.bcolor = LColor.new(255,255,255,255)

    mesh:setRenderType("normal")
    return mesh
end


local function NormalizeVector(vector)
    local dist = math.sqrt(vector[1]^2 + vector[2]^2 + vector[3]^2)
    return {
        vector[1]/dist,
        vector[2]/dist,
        vector[3]/dist,
    }
end

local function CrossProduct(a,b)
    return {
        a[2]*b[3] - a[3]*b[2],
        a[3]*b[1] - a[1]*b[3],
        a[1]*b[2] - a[2]*b[1],
    }
end

function Mesh3D:setBaseColor(color)
    self.bcolor = color
    
end

-- populate model's normals in model's mesh automatically
function Mesh3D:makeNormals()
    for i=1, #self.verts, 3 do
        local vp = self.verts[i]
        local v = self.verts[i+1]
        local vn = self.verts[i+2]

        local vec1 = {v[1]-vp[1], v[2]-vp[2], v[3]-vp[3]}
        local vec2 = {vn[1]-v[1], vn[2]-v[2], vn[3]-v[3]}
        local normal = NormalizeVector(CrossProduct(vec1,vec2))
        vp[6] = normal[1]
        vp[7] = normal[2]
        vp[8] = normal[3]

        v[6] = normal[1]
        v[7] = normal[2]
        v[8] = normal[3]

        vn[6] = normal[1]
        vn[7] = normal[2]
        vn[8] = normal[3]
    end
end

function Mesh3D:useLights()
    if self.rendertype == 'normalmap' then
        local  normalmap = RenderSet.getNormalMap(self.normalmap)
        self.shader = Shader.GeNormal3DShader();
        return
    elseif self.rendertype == 'depth' then
        self.shader = Shader.GeDepth3DShader()
        return
    end

    if self.nolight then
        return
    end
    if self.rendertype ~=  "normal" then
        return
    end
    local directionlights = _G.Lights.getDirectionLights()

    if #directionlights == 0 then
        return
    end

    self.shader = Shader.GetBase3DShader();
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

function Mesh3D:draw()
    if not self.visible then return end
    local camera3d = _G.getGlobalCamera3D()
    --modelMatrix, projectionMatrix, viewMatrix

    RenderSet.setNormalMap(self.normalmap)
    self:useLights()
    self.shader:setCameraAndMatrix3D(self.transform3d, RenderSet.getUseProjectMatrix(), RenderSet.getUseViewMatrix(), camera3d.eye)

    if self.shader:hasUniform( "bcolor") and self.bcolor then
        self.shader:send('bcolor',{self.bcolor._r, self.bcolor._g, self.bcolor._b, self.bcolor._a})
    end
    Render.RenderObject(self)
    RenderSet.setNormalMap()
end

-- stitch two tables together and return the result
-- useful for use in the LoadObjFile function
local concatTables = function(t1,t2,t3)
    local ret = {}

    for i,v in ipairs(t1) do
        ret[#ret +1] = v
    end
    for i,v in ipairs(t2) do
        ret[#ret +1] = v
    end
    for i,v in ipairs(t3) do
        ret[#ret +1] = v
    end

    return ret
end

-- give path of file
-- returns a lua table representation
Mesh3D.loadObjFile = function(path)
    local verts = {}
    local faces = {}
    local uvs = {}
    local normals = {}

    local NeedCreateNormal = true
    -- go line by line through the file
    for line in love.filesystem.lines(path) do
        local words = {}

        -- split the line into words
        for word in line:gmatch("([^".."%s".."]+)") do
            table.insert(words, word)
        end

        -- if the first word in this line is a "v", \then this defines a vertex
        if words[1] == "v" then
            verts[#verts+1] = {tonumber(words[2]), tonumber(words[3]), tonumber(words[4])}
        end

        -- if the first word in this line is a "vt", then this defines a texture coordinate
        if words[1] == "vt" then
            uvs[#uvs+1] = {tonumber(words[2]), tonumber(words[3])}
        end

        -- if the first word in this line is a "vn", then this defines a vertex normal
        if words[1] == "vn" then
            normals[#normals+1] = {tonumber(words[2]), tonumber(words[3]), tonumber(words[4])}
            NeedCreateNormal = false
        end

        -- if the first word in this line is a "f", then this is a face
        -- a face takes three arguments which refer to points, each of those points take three arguments
        -- the arguments a point takes is v,vt,vn
        if words[1] == "f" then
            local store = {}
            for i=2, #words do
                local num = ""
                local word = words[i]
                local ii = 1
                local char = word:sub(ii,ii)

                while true do
                    char = word:sub(ii,ii)
                    if char ~= "/" then
                        num = num .. char
                    else
                        break
                    end
                    ii = ii + 1
                end
                store[#store+1] = tonumber(num)

                local num = ""
                ii = ii + 1
                while true do
                    char = word:sub(ii,ii)
                    if ii <= #word and char ~= "/" then
                        num = num .. char
                    else
                        break
                    end
                    ii = ii + 1
                end
                store[#store+1] = tonumber(num)

                local num = ""
                ii = ii + 1
                while true do
                    char = word:sub(ii,ii)
                    if ii <= #word and char ~= "/" then
                        num = num .. char
                    else
                        break
                    end
                    ii = ii + 1
                end
                store[#store+1] = tonumber(num)
            end

            faces[#faces+1] = store
        end
    end

    if NeedCreateNormal then
        assert(#verts %3 == 0, "verts number is error : " .. tostring(#verts))
        for i = 1, #verts, 3 do
            local v1 = Vector3.new(verts[i][1], verts[i][2], verts[i][3])
            local v2 = Vector3.new(verts[i + 1][1], verts[i + 1][2], verts[i + 1][3])
            local v3 = Vector3.new(verts[i + 2][1], verts[i + 2][2], verts[i + 2][3])

            local v11 = v2 - v1
            local v22 = v3 - v1
            local result = Vector3.cross(v11, v22)

            normals[#normals+1] = {tonumber(result.x), tonumber(result.y), tonumber(result.z)}
            normals[#normals+1] = {tonumber(result.x), tonumber(result.y), tonumber(result.z)}
            normals[#normals+1] = {tonumber(result.x), tonumber(result.y), tonumber(result.z)}
        end
    end
    -- put it all together in the right order
    local compiled = {}
    for i,face in pairs(faces) do
        if NeedCreateNormal then
            compiled[#compiled +1] = concatTables(verts[face[1]], uvs[face[2]], normals[i])
            compiled[#compiled +1] = concatTables(verts[face[3]], uvs[face[4]], normals[i])
            compiled[#compiled +1] = concatTables(verts[face[5]], uvs[face[6]], normals[i])
        else
            compiled[#compiled +1] = concatTables(verts[face[1]], uvs[face[2]], normals[face[3]])
            compiled[#compiled +1] = concatTables(verts[face[4]], uvs[face[5]], normals[face[6]])
            compiled[#compiled +1] = concatTables(verts[face[7]], uvs[face[8]], normals[face[9]])
        end
        
    end

    return compiled
end

_G.MeshLine = {}

function MeshLine.new(startpos, endpos)
    local mesh = setmetatable({}, MeshLine);
    mesh.transform3d = Matrix3D.new();

    mesh.shader = Shader.GetLines3DShader()
    
    mesh.bcolor = LColor.new(255,255,255,255)

    startpos = startpos or Vector3.new(0,0,0)
    endpos = endpos or Vector3.new(0,0,0)

    mesh.verts = {{startpos.x, startpos.y, startpos.z, 0, 0, 1,1,1,1}, 
    {endpos.x, endpos.y, endpos.z, 1, 1, 1,1,1,1}}

    mesh.obj = love.graphics.newMesh(vertexFormat, mesh.verts, "lines")

    mesh.renderid = Render.MeshLineId;
    return mesh;
end

function MeshLine:setStart(x, y, z)
    self:setVertex(1, x, y, z, 0, 0, 1,1,1,1)
end

function MeshLine:setEnd(x, y, z)
    self:setVertex(2, x, y, z, 1, 1, 1,1,1,1)
end

function MeshLine:setStartVector(v)
    self:setVertex(0, v.x, v.y, v.z, 0, 0, 1,1,1,1)
end

function MeshLine:setEndVector(v)
    self:setVertex(1, v.x, v.y, v.z, 1, 1, 1,1,1,1)
end


MeshLine.__index = function(tab, key, ...)
    local value = rawget(tab, key);
    if value then
        return value;
    end

    if MeshLine[key] then
        return MeshLine[key];
    end
    
    if tab["obj"] and tab["obj"][key] then
        if type(tab["obj"][key]) == "function" then
            tab[key] = function(tab, ...)
                return tab["obj"][key](tab["obj"], ...);--todo..
            end
            return  tab[key]
        end
        return tab["obj"][key];
    end

    return nil;
end

MeshLine.__newindex = function(tab, key, value)
    rawset(tab, key, value);
end

function MeshLine:draw()
    self.shader:setCameraAndMatrix3D(self.transform3d, RenderSet.getUseProjectMatrix(), RenderSet.getUseViewMatrix())

    if self.shader:hasUniform( "bcolor") and self.bcolor then
        self.shader:send('bcolor',{self.bcolor._r, self.bcolor._g, self.bcolor._b, self.bcolor._a})
    end
    Render.RenderObject(self);
end

_G.MeshLines = {}
function MeshLines.new(points)
    local mesh = setmetatable({}, {__index = MeshLines});
    -- mesh.transform3d = Matrix3D.new();
    mesh.lines = {}
    for i = 1, #points, 2 do
        table.insert(mesh.lines, MeshLine.new(points[i], points[i + 1]))
    end
    mesh.renderid = Render.MeshLinesId
    return mesh;
end

function MeshLines:setTransform(transform)
    for i = 1, #self.lines do
        self.lines[i].transform3d = Matrix3D.copy(transform)
    end
end

function MeshLines:setBGColor(color)
    for i = 1, #self.lines do
        self.lines[i].bcolor = color
    end
end

function MeshLines:draw()
    for i = 1, #self.lines do
        self.lines[i]:draw()
    end
end
