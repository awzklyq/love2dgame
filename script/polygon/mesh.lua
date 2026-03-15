_G.Mesh = {}


local vertexFormat = {
    {"VertexPosition", "float", 2},
    {"VertexTexCoord", "float", 2},
    {"VertexColor", "float", 4},--normal
    -- {"ConstantColor", "byte", 4},
}

function Mesh.new(vertices, mode, usage)
    local mesh = setmetatable({}, Mesh);
    -- mesh.obj = love.graphics.newMesh(vertices, mode, usage)
    mesh.obj = love.graphics.newMesh(vertexFormat, vertices, mode or "fan")

    mesh.transform = Matrix.new()
    mesh.renderid = Render.MeshId ;
    return mesh
end

Mesh.__index = function(tab, key, ...)
    local value = rawget(tab, key);
    if value then
        return value;
    end

    if Mesh[key] then
        return Mesh[key];
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

Mesh.__newindex = function(tab, key, value)
    rawset(tab, key, value);
end

function Mesh:setCanvas(canvas)
    self:setTexture(canvas.obj)
end

function Mesh:Flush()
    self:flush()
end

-- Mesh:setVertex( index, x, y, u, v, r, g, b, a )

function Mesh:SetVertex(InIndex, InData)
    self:setVertex( InIndex, InData[1], InData[2], InData[3], InData[4], InData[5], InData[6], InData[7], InData[8])

    -- self:Flush()
end

function Mesh:setBaseTexture(canvas)
    if not canvas then
        self.shader = Shader.GetBaseShader()
    else
        self.shader = Shader.GetBaseImageShader()
        self.shader:setBaseImage(canvas.obj)
    end
end


function Mesh:draw()
    if self.UpdateShaderValue then
        self:UpdateShaderValue()
    end
    Render.RenderObject(self);
end

Mesh.CreteMeshFormSimpleConcavePolygon = function(vertices, ...)
    local num = #vertices

    local colors = {...}
    local minx, miny, maxx, maxy = 0, 0, 0, 0
    for i = 1, num, 2 do
        minx = math.min(minx,  vertices[i])
        miny = math.min(miny,  vertices[i +1])

        maxx = math.max(maxx,  vertices[i])
        maxy = math.max(maxy,  vertices[i +1])
    end

    local datas = {}
    for i = 1, #vertices, 2 do
        local color = colors[i % #colors + 1]
        if #colors == 1 then
            color = colors[1]
        end
        table.insert(datas, {vertices[i], vertices[i +1], -- position of the vertex
        (vertices[i] - minx) / (maxx - minx), (vertices[i + 1] - miny) / (maxy - miny), -- texture coordinate at the vertex position
        color._r, color._g, color._b, color._a})
    end

    return Mesh.new(datas);
end

_G.MeshQuad = {}

_G.MeshQuad.new = function(w, h, color, img)
    -- local vertices = {-w * 0.5, -h * 0.5, 
    -- w * 0.5, -h * 0.5,
    -- w * 0.5, h * 0.5,
    -- -w * 0.5, h * 0.5};

    local vertices = {0 , 0 , 
    0 , h ,
    w , h ,
    w , 0 };

    local mesh = Mesh.CreteMeshFormSimpleConcavePolygon(vertices, color);
    if img then
        if img.obj then
            mesh:setTexture(img.obj)
        else
            mesh:setTexture(img)
        end
        
    end

    mesh.shader = Shader.GetBaseShader()

    return mesh;
end

_G.MeshQuadBlur = {}

_G.MeshQuadBlur.new = function(w, h, color)
    -- local vertices = {-w * 0.5, -h * 0.5, 
    -- w * 0.5, -h * 0.5,
    -- w * 0.5, h * 0.5,
    -- -w * 0.5, h * 0.5};

    local vertices = {0 , 0 , 
    0 , h ,
    w , h ,
    w , 0 };

    local mesh = Mesh.CreteMeshFormSimpleConcavePolygon(vertices, color);

    mesh.shader = Shader.GetImageBlurShader()

    mesh.BindImage = function(obj, img, imgw, imgh)
        obj.image = img
        obj.imgw = imgw or  obj.image.w
        obj.imgh = imgh or  obj.image.h   
    end

    mesh.UpdateShaderValue = function(obj)
        obj.shader:SetImageBlurShader(obj.image.obj, obj.imgw, obj.imgh, obj.BlurSizeX / obj.imgw ,  obj.BlurSizeY / obj.imgh ,  (obj.BlurSizeX + obj.BlurSizeW) / obj.imgw, (obj.BlurSizeY + obj.BlurSizeH) / obj.imgh, obj.offset, obj.blurnum, obj.power)
    end

    mesh.BlurSize = function(obj, x, y, w, h)
        obj.BlurSizeX = x or 0
        obj.BlurSizeY = y or 0
        obj.BlurSizeW = w or obj.imgw
        obj.BlurSizeH = h or obj.imgh
    end

    return mesh;
end


_G.MeshGrids = {}

_G.MeshGrids.new = function(InStartX, InStartY, w, h, wn, hn, color, img, InFunc)
    -- local vertices = {-w * 0.5, -h * 0.5, 
    -- w * 0.5, -h * 0.5,
    -- w * 0.5, h * 0.5,
    -- -w * 0.5, h * 0.5};

    local _OffsetX = w / wn
    local _OffsetY = h / hn

    local _StartX = InStartX
    local _StartY = InStartY
    local _AllVertices = {}
    local _AllUVs = {}
    local Indexs = {}
    for i = 1, wn do
        for j = 1, hn do
            local vertices = {0 , 0 , 
            0 , h ,
            w , h ,
            w , 0 };

            local sx = _StartX + (i - 1) * _OffsetX
            local sy = _StartY + (j - 1) * _OffsetY

            local v1 = {sx, sy}
            local v2 = {sx, sy + _OffsetY}
            local v3 = {sx + _OffsetX, sy + _OffsetY}

            local v4 = {sx, sy}
            local v5 = {sx + _OffsetX, sy + _OffsetY}
            local v6 = {sx + _OffsetX, sy}

            _AllVertices[#_AllVertices + 1] = v1
            _AllVertices[#_AllVertices + 1] = v2
            _AllVertices[#_AllVertices + 1] = v3

            _AllVertices[#_AllVertices + 1] = v4
            _AllVertices[#_AllVertices + 1] = v5
            _AllVertices[#_AllVertices + 1] = v6

            local index1 = {i, j}
            local index2 = {i, j + 1}
            local index3 = {i + 1, j + 1}

            local index4 = {i, j}
            local index5 = {i + 1, j + 1}
            local index6 = {i + 1, j}

            Indexs[#Indexs + 1] = index1
            Indexs[#Indexs + 1] = index2
            Indexs[#Indexs + 1] = index3

            Indexs[#Indexs + 1] = index4
            Indexs[#Indexs + 1] = index5
            Indexs[#Indexs + 1] = index6

            local uv1 = {(v1[1] - _StartX) / w, (v1[2] - _StartY) / h }
            local uv2 = {(v2[1] - _StartX) / w, (v2[2] - _StartY) / h }
            local uv3 = {(v3[1] - _StartX) / w, (v3[2] - _StartY) / h }
            local uv4 = {(v4[1] - _StartX) / w, (v4[2] - _StartY) / h }
            local uv5 = {(v5[1] - _StartX) / w, (v5[2] - _StartY) / h }
            local uv6 = {(v6[1] - _StartX) / w, (v6[2] - _StartY) / h }

            _AllUVs[#_AllUVs + 1] = uv1
            _AllUVs[#_AllUVs + 1] = uv2
            _AllUVs[#_AllUVs + 1] = uv3

            _AllUVs[#_AllUVs + 1] = uv4
            _AllUVs[#_AllUVs + 1] = uv5
            _AllUVs[#_AllUVs + 1] = uv6

        end
    end
    
    
    local _Datas = {}
    for i = 1, #_AllVertices do
        local _Data = {}
        _Data[#_Data + 1] = _AllVertices[i][1]
        _Data[#_Data + 1] = _AllVertices[i][2]

        _Data[#_Data + 1] = _AllUVs[i][1]
        _Data[#_Data + 1] = _AllUVs[i][2]

        _Data[#_Data + 1] = color._r
        _Data[#_Data + 1] = color._g
        _Data[#_Data + 1] = color._b
        _Data[#_Data + 1] = color._a

        if InFunc then
            InFunc(#_Datas + 1, Indexs[i][1], Indexs[i][2], _Data, _AllVertices[i][1], _AllVertices[i][2])
        end
        _Datas[#_Datas + 1] = _Data
    end

    local mesh = Mesh.new(_Datas, "triangles");
    if img then
        if img.obj then
            mesh:setTexture(img.obj)
        else
            mesh:setTexture(img)
        end
        
    end

    mesh.shader = Shader.GetBaseShader()

    return mesh;
end