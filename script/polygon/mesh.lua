_G.Mesh = {}

function Mesh.new(vertices, mode, usage)
    local mesh = setmetatable({}, Mesh);
    mesh.obj = love.graphics.newMesh(vertices, mode, usage)

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

function Mesh:setBaseTexture(canvas)
    if not canvas then
        self.shader = Shader.GetBaseShader()
    else
        self.shader = Shader.GetBaseImageShader()
        self.shader:setBaseImage(canvas.obj)
    end
end


function Mesh:draw()
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
        if img.renderid == Render.CanvasId then
            mesh:setTexture(img.obj)
        else
            mesh:setTexture(img)
        end
        
    end

    mesh.shader = Shader.GetBaseShader()

    return mesh;
end


