_G.Mesh = {}

function Mesh.new(vertices, mode, usage)
    local mesh = setmetatable({}, Mesh);
    mesh.mesh = love.graphics.newMesh(vertices, mode, usage)

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
    
    if tab["mesh"] and tab["mesh"][key] then
        if type(tab["mesh"][key]) == "function" then
            tab[key] = function(tab, ...)
                return tab["mesh"][key](tab["mesh"], ...);--todo..
            end
            return  tab[key]
        end
        return tab["mesh"][key];
    end

    return nil;
end

Mesh.__newindex = function(tab, key, value)
    rawset(tab, key, value);
end

function Mesh:draw()
    Render.RenderObject(self);
end

Mesh.CreteMeshFormSimpleConcavePolygon = function(vertices, color)
    local centerx, centery = 0, 0
    local num = #vertices
    

    local minx, miny, maxx, maxy = 0, 0, 0, 0
    for i = 1, num, 2 do
        centerx = centerx + vertices[i];
        centery = centery + vertices[i +1]

        minx = math.min(minx,  vertices[i])
        miny = math.min(miny,  vertices[i +1])

        maxx = math.max(minx,  vertices[i])
        maxy = math.max(miny,  vertices[i +1])
    end

    centerx = centerx / (num / 2)
    centery = centery / (num / 2)

    local sizex, sizey
    local datas = {}
    for i = 1, num, 4 do
        local triangles1 = {
			-- top-left corner (red-tinted)
			vertices[i], vertices[i +1], -- position of the vertex
			(vertices[i] - minx) / (maxx - minx), (vertices[i + 1] - miny) / (maxy - miny), -- texture coordinate at the vertex position
			1, 0, 0, -- color of the vertex
        }

        local triangles2 = {
			-- top-left corner (red-tinted)
			centerx, centery, -- position of the vertex
			(centerx - minx) / (maxx - minx), (centery - miny) / (maxy - miny), -- texture coordinate at the vertex position
			1, 0, 0, -- color of the vertex
        }

        local triangles3 = {
			-- top-left corner (red-tinted)
			vertices[i + 2], vertices[i +3], -- position of the vertex
			(vertices[i + 2] - minx) / (maxx - minx), (vertices[i +3] - miny) / (maxy - miny), -- texture coordinate at the vertex position
			1, 0, 0, -- color of the vertex
        }
        datas[#datas + 1] = triangles1
        datas[#datas + 1] = triangles2
        datas[#datas + 1] = triangles3
    end
    -- for i = 1, num, 4 do
    --     table.insert(triangles, vertices[i])
    --     table.insert(triangles, vertices[i +1])

    --     table.insert(triangles, centerx)
    --     table.insert(triangles, centery)

    --     table.insert(triangles, vertices[i +2])
    --     table.insert(triangles, vertices[i +3])
    -- end

    return Mesh.new(datas);
end
