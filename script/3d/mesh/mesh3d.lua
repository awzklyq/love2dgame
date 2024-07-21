_G.__createClassFromLoveObj("Mesh3D")

local vertexFormat = {
    {"VertexPosition", "float", 3},
    {"VertexTexCoord", "float", 2},
    {"VertexColor", "float", 3},--normal
    {"ConstantColor", "byte", 4},
}

function Mesh3D.new(file)-- lw :line width
    return Mesh3D.createFromPoints(Mesh3D.loadObjFile(_G.FileManager.findFile(file)))
end

function Mesh3D:setCanvas(canvas)
    self:setTexture(canvas.obj)
end

function Mesh3D:SetImage(image)
    self:setTexture(image.obj)
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

    mesh.PreTransform = Matrix3D.new();

    mesh.verts = datas
    mesh.shader = Shader.GetBase3DShader()
    mesh:makeNormals()
    mesh.obj = love.graphics.newMesh(vertexFormat, mesh.verts, "triangles")

    mesh.bcolor = LColor.new(255,255,255,255)
    mesh.renderid = Render.Mesh3DId;

    mesh.rendertype = "normal"

    mesh.nolight = false

    mesh.visible = true

    mesh.box = BoundBox.buildFromMesh3D(mesh)

    mesh:setRenderType("normal")
    return mesh;
end

function Mesh3D:GetWorldBox()
    return self.transform3d:mulBoundBox(self.box)
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

function Mesh3D:GetPositions()
    local result = {}
    for i, v in pairs(self.verts) do
        result[#result + 1] = Vector3.new(v[1], v[2], v[3])
    end
    return result
end

-- populate model's normals in model's mesh automatically
function Mesh3D:makeNormals()
    self.FacesInfos = {}
    local _MeshBox = BoundBox.new()
    for i=1, #self.verts, 3 do
        local vp = self.verts[i]
        local v = self.verts[i+1]
        local vn = self.verts[i+2]

        local vec1 = {v[1]-vp[1], v[2]-vp[2], v[3]-vp[3]}
        local vec2 = {vn[1]-v[1], vn[2]-v[2], vn[3]-v[3]}
        local normal = NormalizeVector(CrossProduct(vec1,vec2))
        -- vp[6] = normal[1]
        -- vp[7] = normal[2]
        -- vp[8] = normal[3]

        -- v[6] = normal[1]
        -- v[7] = normal[2]
        -- v[8] = normal[3]

        -- vn[6] = normal[1]
        -- vn[7] = normal[2]
        -- vn[8] = normal[3]

        if not vp.FaceNormal then
            vp.FaceNormal = {} 
        end

        if not v.FaceNormal then
            v.FaceNormal = {} 
        end

        if not vn.FaceNormal then
            vn.FaceNormal = {} 
        end

        local FaceNormal = Vector3.new(normal[1], normal[2], normal[3])

        vp.FaceNormal[#vp.FaceNormal + 1] = FaceNormal
        v.FaceNormal[#v.FaceNormal + 1] = FaceNormal
        vn.FaceNormal[#vn.FaceNormal + 1] = FaceNormal

        local FaceInfo = {}
        FaceInfo.Normal = FaceNormal
        FaceInfo.Triangle = Triangle3D.new(Vector3.new(vp[1], vp[2], vp[3]), Vector3.new(v[1], v[2], v[3]), Vector3.new(vn[1], vn[2], vn[3]))
        FaceInfo.TriangleCenter = (FaceInfo.Triangle.P1 + FaceInfo.Triangle.P2 + FaceInfo.Triangle.P3) / 3
        _MeshBox = _MeshBox + FaceInfo.Triangle.P1
        _MeshBox = _MeshBox + FaceInfo.Triangle.P2
        _MeshBox = _MeshBox + FaceInfo.Triangle.P3
        -- FaceInfo.TriangleMortonCode = FaceInfo.TriangleCenter:GetMortonCode3()

        self.FacesInfos[#self.FacesInfos + 1] = FaceInfo
    end

    for i=1, #self.verts, 1 do
        local v = self.verts[i]
        local nor = Vector3.new()
        for f = 1, #v.FaceNormal do
            nor = nor + v.FaceNormal[f]
        end

        nor:normalize()

        v[6] = nor.x
        v[7] = nor.y
        v[8] = nor.z
    end

    local _Size = _MeshBox.max - _MeshBox.min 
    for i = 1, #self.FacesInfos do
        local VM = Vector3.Copy(self.FacesInfos[i].TriangleCenter)
        VM = (VM - _MeshBox.min) / _Size * 1023;
        self.FacesInfos[i].TriangleMortonCode = VM:GetMortonCode3()
    end


    math.SortLargeArray(self.FacesInfos, function(v1,v2)
        if v1.TriangleMortonCode > v2.TriangleMortonCode then
            return true
        end
        return false
    end)

    self:BuildBVHFormFacesInfos();
end

function Mesh3D:BuildBVHFormFacesInfos()
    self.FacesInfosBVH = {}
    local _Len =  #self.FacesInfos

    local _box = BoundBox.new()
    local _IndexArray = {}

    for i = 1, #self.FacesInfos do
        if i == 1 then
            _box = _box + self.FacesInfos[i].Triangle.P1
            _box = _box + self.FacesInfos[i].Triangle.P2
            _box = _box + self.FacesInfos[i].Triangle.P3
            _IndexArray[#_IndexArray + 1] = i
        
        elseif i ==  #self.FacesInfos then
            _errorAssert(#self.FacesInfos > 2, "BuildBVHFormFacesInfos self.FacesInfos <= 2")

            if #_IndexArray > 1 then
                self.FacesInfosBVH[#self.FacesInfosBVH + 1] = {Box = _box, IndexArray = _IndexArray}
            end

            _box = BoundBox.new()
            _IndexArray = {}
            _box = _box + self.FacesInfos[i].Triangle.P1
            _box = _box + self.FacesInfos[i].Triangle.P2
            _box = _box + self.FacesInfos[i].Triangle.P3
            _IndexArray[#_IndexArray + 1] = i

            if #_IndexArray > 0 then
                self.FacesInfosBVH[#self.FacesInfosBVH + 1] = {Box = _box, IndexArray = _IndexArray}
            end
            
        else
            local LeftNum = math.BitEquationRightNumber(self.FacesInfos[i].TriangleMortonCode,  self.FacesInfos[i - 1].TriangleMortonCode)
            local RightNum = math.BitEquationRightNumber(self.FacesInfos[i].TriangleMortonCode,  self.FacesInfos[i + 1].TriangleMortonCode)
            if LeftNum >= RightNum  then
                _box = _box + self.FacesInfos[i].Triangle.P1
                _box = _box + self.FacesInfos[i].Triangle.P2
                _box = _box + self.FacesInfos[i].Triangle.P3
                _IndexArray[#_IndexArray + 1] = i
            else
                if #_IndexArray > 0 then
                    self.FacesInfosBVH[#self.FacesInfosBVH + 1] = {Box = _box, IndexArray = _IndexArray}
                end

                _box = BoundBox.new()
                _IndexArray = {}
                _box = _box + self.FacesInfos[i].Triangle.P1
                _box = _box + self.FacesInfos[i].Triangle.P2
                _box = _box + self.FacesInfos[i].Triangle.P3
                _IndexArray[#_IndexArray + 1] = i
            end
        end
               
    end

    self:BuildBVHFormFacesInfosAgain()
end


function Mesh3D:BuildBVHFormFacesInfosAgain()
    if not self.FacesInfosBVH then
        return
    end

    local _Len =  #self.FacesInfosBVH

    local TempFacesInfosBVH = {}
    local _box = BoundBox.new()
    local _IndexArray = {}

    for i = 1, _Len do
        if i == 1 then
            _box = _box + self.FacesInfosBVH[i].Box
            math.AppendArray( _IndexArray, self.FacesInfosBVH[i].IndexArray)
        
        elseif i ==  _Len then
            _errorAssert(_Len > 2, "BuildBVHFormFacesInfos self.FacesInfosBVH <= 2")

            if #_IndexArray > 1 then
                TempFacesInfosBVH[#TempFacesInfosBVH + 1] = {Box = _box, IndexArray = _IndexArray}
            end

            _box = BoundBox.new()
            _IndexArray = {}
            _box = _box + self.FacesInfosBVH[i].Box
            math.AppendArray( _IndexArray, self.FacesInfosBVH[i].IndexArray)

            if #_IndexArray > 0 then
                TempFacesInfosBVH[#TempFacesInfosBVH + 1] = {Box = _box, IndexArray = _IndexArray}
            end
            
        else
            local LeftNum = math.BitEquationRightNumber(self.FacesInfos[self.FacesInfosBVH[i].IndexArray[1]].TriangleMortonCode,  self.FacesInfos[self.FacesInfosBVH[i - 1].IndexArray[1]].TriangleMortonCode)
            local RightNum = math.BitEquationRightNumber(self.FacesInfos[self.FacesInfosBVH[i].IndexArray[1]].TriangleMortonCode,  self.FacesInfos[self.FacesInfosBVH[i + 1].IndexArray[1]].TriangleMortonCode)
            if LeftNum >= RightNum  then
                _box = _box + self.FacesInfosBVH[i].Box
                math.AppendArray( _IndexArray, self.FacesInfosBVH[i].IndexArray)
            else
                if #_IndexArray > 0 then
                    TempFacesInfosBVH[#TempFacesInfosBVH + 1] = {Box = _box, IndexArray = _IndexArray}
                end

                _box = BoundBox.new()
                _IndexArray = {}
                _box = _box + self.FacesInfosBVH[i].Box
                math.AppendArray( _IndexArray, self.FacesInfosBVH[i].IndexArray)
            end
        end
               
    end

    self.FacesInfosBVH = TempFacesInfosBVH
end


function Mesh3D:useLights(alphatest)
    self.shader = Shader.GetBase3DShader(nil, nil, nil, nil, alphatest, self.PBRData);
    self.shader:SetPBRValue(self.PBRData)
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

    if #directionlights > 0 then
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
end

function Mesh3D:draw()
    if not self.visible then return end

    local camera3d = _G.getGlobalCamera3D()
    --modelMatrix, projectionMatrix, viewMatrix

    RenderSet.setNormalMap(self.normalmap)
    self:useLights()

    self.shader:setCameraAndMatrix3D(self.transform3d, RenderSet.getUseProjectMatrix(), RenderSet.getUseViewMatrix(), camera3d.eye, self)
    
    if self.shader:hasUniform( "bcolor") and self.bcolor then
        self.shader:send('bcolor',{self.bcolor._r, self.bcolor._g, self.bcolor._b, self.bcolor._a})
    end
    Render.RenderObject(self)
    RenderSet.setNormalMap()

    self:AfterDraw()
end

function Mesh3D:DrawPrePassBlack()
    if not self.visible then return end

    local camera3d = _G.getGlobalCamera3D()
    --modelMatrix, projectionMatrix, viewMatrix

    local shader = self.shader
    self.shader = Shader.GetPrePassBlack3DShader(nil, nil, nil, nil);
     
    self.shader:setCameraAndMatrix3D(self.transform3d, RenderSet.getUseProjectMatrix(), RenderSet.getUseViewMatrix(), camera3d.eye, self)

    Render.RenderObject(self)

    self.shader = shader

    self:AfterDraw()
end

function Mesh3D:AfterDraw()
    --self.PreTransform = Matrix3D.copy(self.transform3d)
end

function Mesh3D:DrawAlphaTest(DepthTexture, ColorTexture, BlendCoef)
    if not self.visible then return end
    local camera3d = _G.getGlobalCamera3D()
    --modelMatrix, projectionMatrix, viewMatrix

    RenderSet.setNormalMap(self.normalmap)
    self:useLights(true)
    self.shader:setCameraAndMatrix3D(self.transform3d, RenderSet.getUseProjectMatrix(), RenderSet.getUseViewMatrix(), camera3d.eye)

    self.shader:SetAlpahTestValue(DepthTexture, ColorTexture, BlendCoef)
    if self.shader:hasUniform( "bcolor") and self.bcolor then
        self.shader:send('bcolor',{self.bcolor._r, self.bcolor._g, self.bcolor._b, self.bcolor._a})
    end
    Render.RenderObject(self)
    RenderSet.setNormalMap()
end

function Mesh3D:DrawAlphaTest2(ColorTexture, BlendCoef)
    if not self.visible then return end
    local camera3d = _G.getGlobalCamera3D()
    --modelMatrix, projectionMatrix, viewMatrix

    RenderSet.setNormalMap(self.normalmap)
    self:useLights(true)
    self.shader:setCameraAndMatrix3D(self.transform3d, RenderSet.getUseProjectMatrix(), RenderSet.getUseViewMatrix(), camera3d.eye)

    self.shader:SetAlpahTestValue(nil, ColorTexture, BlendCoef)
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

    if t2 then
        for i,v in ipairs(t2) do
            ret[#ret +1] = v
        end
    else
        ret[#ret +1] = 0
        ret[#ret +1] = 0
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
            compiled[#compiled +1] = concatTables(verts[face[3]], uvs[face[4]], normals[i])
            compiled[#compiled +1] = concatTables(verts[face[1]], uvs[face[2]], normals[i])
           -- compiled[#compiled +1] = concatTables(verts[face[3]], uvs[face[4]], normals[i])
            compiled[#compiled +1] = concatTables(verts[face[5]], uvs[face[6]], normals[i])
        else
            if #uvs > 0 then
                compiled[#compiled +1] = concatTables(verts[face[4]], uvs[face[5]], normals[face[6]])
                compiled[#compiled +1] = concatTables(verts[face[1]], uvs[face[2]], normals[face[3]])
                --compiled[#compiled +1] = concatTables(verts[face[4]], uvs[face[5]], normals[face[6]])
                compiled[#compiled +1] = concatTables(verts[face[7]], uvs[face[8]], normals[face[9]])
            else
                if #face > 6 then
                    compiled[#compiled +1] = concatTables(verts[face[3]], nil, normals[face[4]])
                    compiled[#compiled +1] = concatTables(verts[face[1]], nil, normals[face[2]])
                    --compiled[#compiled +1] = concatTables(verts[face[3]], nil, normals[face[4]])
                    compiled[#compiled +1] = concatTables(verts[face[5]], nil, normals[face[6]])
                    
                    
                    compiled[#compiled +1] = concatTables(verts[face[7]], nil, normals[face[8]])
                    -- compiled[#compiled +1] = concatTables(verts[face[3]], nil, normals[face[4]])
                    compiled[#compiled +1] = concatTables(verts[face[5]], nil, normals[face[6]])
                    --compiled[#compiled +1] = concatTables(verts[face[7]], nil, normals[face[8]])
                    compiled[#compiled +1] = concatTables(verts[face[1]], nil, normals[face[2]])
                else
                    compiled[#compiled +1] = concatTables(verts[face[3]], nil, normals[face[4]])
                    compiled[#compiled +1] = concatTables(verts[face[1]], nil, normals[face[2]])
                    --compiled[#compiled +1] = concatTables(verts[face[3]], nil, normals[face[4]])
                    compiled[#compiled +1] = concatTables(verts[face[5]], nil, normals[face[6]])                    
                end

            end
        end
        
    end

    return compiled
end

-- Return distance
function Mesh3D:PickByRay(ray)
    local box = self:GetWorldBox()
    if  ray:IsIntersectBox(box) then
        return self:PickFaceByRay(ray)
    end

    return -1
end

-- Return distance
function Mesh3D:PickFaceByRay(ray)
    if #self.FacesInfos == 0 then
        return -1
    end
    
    for i = 1, #self.FacesInfos do
        local dis = ray:IntersectTriangle(self.transform3d * self.FacesInfos[i].Triangle, true)
        if dis > 0 then
            return dis
        end
    end
    return -1
end

function Mesh3D:PickFaceAndBVHByRay(ray, backcull)
    if #self.FacesInfos == 0 or #self.FacesInfosBVH == 0 then
        return -1
    end

    for i = 1, #self.FacesInfosBVH do
        local _FaceBVH = self.FacesInfosBVH[i]
       if ray:IsIntersectBox(self.transform3d * _FaceBVH.Box) then
            for _, index in ipairs(_FaceBVH.IndexArray) do
                local dis = ray:IntersectTriangle(self.transform3d * self.FacesInfos[index].Triangle, backcull)
                if dis > 0 then
                    return dis
                end
            end
       end
    end

    return -1
end

function Mesh3D:IntersectFaceAndBVHByBox(InBox)
    if #self.FacesInfos == 0 or #self.FacesInfosBVH == 0 then
        return false
    end

    for i = 1, #self.FacesInfosBVH do
        local _FaceBVH = self.FacesInfosBVH[i]
        if BoundBox.checkIntersectBox(InBox, self.transform3d * _FaceBVH.Box) then
            for _, index in ipairs(_FaceBVH.IndexArray) do
                if InBox:IntersectTriangleSimilar(self.transform3d * self.FacesInfos[index].Triangle) then
                    return true
                end
            end
        end
    end

    return false
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

function MeshLine:setBaseColor(color)
    self.bcolor = color
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

