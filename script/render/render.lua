_G.Render = {};

Render.CircleId = 1;
Render.RectId = 2;

Render.PolygonId = 3;

Render.EntityBodyId = 4;

Render.LineId = 5;

Render.CrossLineId = 6;

Render.PowerBarId = 7;

Render.NoiseLineId = 8;

Render.GridDebugViewId = 9;

Render.BoxBoundId = 10;

Render.MeshId = 11;

Render.Box2dId = 12;

Render.CanvasId = 13;

Render.ShaderId = 14

Render.Camera3DId = 15

Render.Mesh3DId = 16

Render.Vector3Id = 17

Render.DirectionLightId = 18

Render.Scene3DId = 19

Render.SceneNode3DId = 20

Render.ImageId = 21

Render.MeshLineId = 22

Render.FrustumId = 23

Render.MeshLinesId = 24

Render.Vector4Id = 25

Render.MatrixId = 26

Render.Matrix3DId = 27

Render.BoundBoxId = 28

Render.LinesId = 29;

Render.getRenderIdName = function(id)
    if Render.CircleId == id then
        return "Circle"
    elseif Render.RectId == id then
        return "Rect"
    elseif Render.PolygonId == id then
        return "Polygon"
    elseif Render.EntityBodyId == id then
        return "EntityBody"
    elseif Render.LineId == id then
        return "Line"
    elseif Render.CrossLineId == id then
        return "CrossLine"
    elseif Render.PowerBarId == id then
        return "PowerBar"
    elseif Render.NoiseLineId == id then
        return "NoiseLine"
    elseif Render.GridDebugViewId == id then
        return "GridDebugView"
    elseif Render.BoxBoundId == id then
        return "Box"
    elseif Render.MeshId == id then
        return "Mesh"
    elseif Render.CanvasId == id then
        return "Canvas"
    elseif Render.ShaderId == id then
        return "Shader"
    elseif Render.Vector3Id == id then
        return "Vector3"
    elseif Render.DirectionLightId == id then
        return "DirectionLight"
    elseif Render.Scene3DId == id then
        return "Scene3D"
    elseif Render.SceneNode3DId == id then
        return "SceneNode3D"
    elseif Render.ImageId == id then
        return "image"
    elseif Render.MeshLineId == id then
        return "Line3D"
    elseif Render.FrustumId == id then
        return "Frustum"
    elseif Render.MeshLinesId == id then
        return "MeshLines"
    elseif Render.LinesId == id then
        return "Lines"
    end

    return "Null"
end

Render.RenderObject = function(obj)
    
    if not _G.lovedebug.renderobject then return end
    love.graphics.push();
    if obj.transform and obj.transform.renderid == Render.MatrixId and obj.renderid ~= Render.EntityBodyId then
        obj.transform:use(obj);
    end

    if obj.shader then
        if obj.shader.renderid == Render.ShaderId then
            love.graphics.setShader(obj.shader.obj)
        else
            love.graphics.setShader(obj.shader)
        end
    end

    if _G.lovedebug.renderobject then
        if obj.renderid == Render.CircleId then
            love.graphics.circle( obj.mode, obj.x, obj.y, obj.r, obj.seg);
        elseif obj.renderid == Render.RectId then
            if obj.color then
                love.graphics.setColor(obj.color._r, obj.color._g, obj.color._b, obj.color._a);
            end
            
            love.graphics.rectangle( obj.mode, obj.x, obj.y, obj.w, obj.h);
        elseif obj.renderid == Render.EntityBodyId then
           
            if obj.polygon then
                obj.polygon:draw()
            end

            for i, v in ipairs(obj.children) do
                v:draw();
            end
        elseif obj.renderid == Render.PolygonId then
            
            if #obj.circles > 0 then
                for i= 1, #obj.circles do
                    Render.RenderObject(obj.circles[i])
                end
            end

            if #obj.rects > 0 then
                for i=1, #obj.rects do
                    Render.RenderObject(obj.rects[i])
                end
            end

            if #obj.vertices > 4 then
                if obj.stroke_paint then
                    local lw = love.graphics.getLineWidth();
                    love.graphics.setLineWidth( obj.stroke_width);

                    love.graphics.setColor(obj.stroke_paint.r, obj.stroke_paint.g, obj.stroke_paint.b, obj.stroke_paint.a);
        
                    love.graphics.polygon("line", obj.vertices);
        
                    love.graphics.setLineWidth( lw);
                end
        
                if obj.fill_paint then
                    love.graphics.setColor(obj.fill_paint.r, obj.fill_paint.g, obj.fill_paint.b, obj.fill_paint.a);
                    if obj.isConvex or obj.isConvex == nil then
                        love.graphics.polygon("fill", obj.vertices);
                    elseif #obj.triangles > 0 then
                        for i = 1, #obj.triangles do
                            love.graphics.polygon("fill", obj.triangles[i]);
                        end
                    end
                    
                end
            end

            if obj.usesvgpaths then
                Render.RenderSVGPaths(obj.svgpaths);
            end
        elseif obj.renderid == Render.LineId then
            local lw = love.graphics.getLineWidth();
            love.graphics.setLineWidth( obj.lw);
            love.graphics.setColor(obj.color.r, obj.color.g, obj.color.b, obj.color.a);
            love.graphics.line( obj.x1, obj.y1, obj.x2, obj.y2)
            love.graphics.setLineWidth(lw);
        elseif obj.renderid == Render.LinesId then
            local lw = love.graphics.getLineWidth();
            love.graphics.setLineWidth( obj.lw);
            love.graphics.setColor(obj.color.r, obj.color.g, obj.color.b, obj.color.a);
            if #obj.values > 1 then
                for i = 2, #obj.values do
                    love.graphics.line( obj.values[i - 1].x, obj.values[i - 1].y, obj.values[i].x, obj.values[i].y)
                end
            end
            
            love.graphics.setLineWidth(lw);
        elseif obj.renderid == Render.CrossLineId then
            local lw = love.graphics.getLineWidth();
            love.graphics.setLineWidth( obj.lw);
            love.graphics.setColor(obj.color._r, obj.color._g, obj.color._b);
            love.graphics.line( obj.x - 0.5 * obj.w, obj.y,  obj.x + 0.5 * obj.w, obj.y);
            love.graphics.line( obj.x, obj.y - 0.5 * obj.h,  obj.x, obj.y + 0.5 * obj.h);
            love.graphics.setLineWidth(lw);
        elseif obj.renderid == Render.PowerBarId then
            love.graphics.rectangle("fill", obj.x1, obj.y1, obj.x2 - obj.x1, obj.h)
            love.graphics.setShader()
            local lw = love.graphics.getLineWidth();
            local r, g, b, a = love.graphics.getColor( );
            love.graphics.setColor(obj.color._r, obj.color._g, obj.color._b);
            love.graphics.setLineWidth( obj.lw);
            
            love.graphics.rectangle("line", obj.x1+0.5, obj.y2 - obj.oh+0.5, obj.x2 - obj.x1 -1, obj.oh-1)
            love.graphics.setLineWidth(lw);
            love.graphics.setColor(r, g, b, a);
        elseif obj.renderid == Render.NoiseLineId then 
            local lw = love.graphics.getLineWidth();
            local r, g, b, a = love.graphics.getColor( );
            love.graphics.setLineWidth( obj.lw);
            love.graphics.setColor(obj.color._r, obj.color._g, obj.color._b);
            -- love.graphics.polygon("line", obj.renderdatas)
            -- local poss = {100, 100, 200, 250, 300, 400}
            love.graphics.line(obj.renderdatas)
            love.graphics.setLineWidth(lw);
            love.graphics.setColor(r, g, b, a);
        elseif obj.renderid == Render.GridDebugViewId then 
            obj:renderDebugView()
        elseif obj.renderid == Render.BoxBoundId then 
            local lw = love.graphics.getLineWidth();
            local r, g, b, a = love.graphics.getColor( );
            love.graphics.setLineWidth( 3);
            love.graphics.setColor(0.9, 0.9, 0.0);
            local x1, y1, x2, y2 = obj:getBoxValueFromObj()
            love.graphics.rectangle("line", x1 - 3, y1 - 3, x2 - x1 + 6, y2 - y1 + 6)
            love.graphics.setLineWidth(lw);
            love.graphics.setColor(r, g, b, a);
        elseif obj.renderid == Render.MeshId then
            love.graphics.draw( obj.obj )
        elseif obj.renderid == Render.Mesh3DId then
            love.graphics.draw( obj.obj )
        elseif obj.renderid == Render.MeshLineId then
            love.graphics.draw( obj.obj )
        -- elseif obj.renderid == Render.FrustumId then
        --     love.graphics.draw( obj.obj )
        elseif obj.renderid == Render.CanvasId then
            love.graphics.draw( obj.obj, obj.x, obj.y, 0, obj.renderWidth / obj:getWidth(), obj.renderHeight / obj:getHeight())
        elseif obj.renderid == Render.ImageId then
            love.graphics.draw( obj.obj, obj.x, obj.y, 0, obj.renderWidth / obj:getWidth(), obj.renderHeight / obj:getHeight())
        end

        
        if obj.shader then
            love.graphics.setShader()
        end

        love.graphics.pop();
    end
    
    -- if _G.lovedebug.renderbox2d then
    --     if obj.renderid == Render.Box2dCircleId then
    --         love.graphics.circle("line", obj.body:getX(), obj.body:getY(), obj.shape:getRadius())
    --     elseif obj.renderid == Render.Box2dRectId then
    --         love.graphics.polygon("line", obj.body:getWorldPoints(obj.shape:getPoints()))
    --     end
    -- end
end

Render.RenderSVGPaths = function(svgpaths, first)
    for i, v in pairs(svgpaths) do
        if first then
            love.graphics.push();
        end

        local svgpath = svgpaths[i];

        if svgpath.rotate then
            love.graphics.translate(svgpath.rotate.x, svgpath.rotate.y);
            love.graphics.rotate(svgpath.rotate.a);
            love.graphics.translate(-svgpath.rotate.x, -svgpath.rotate.y);
        end

        if svgpath.scale then
            love.graphics.scale(svgpath.scale.x, svgpath.scale.y)
        end

        if svgpath.translate then
            love.graphics.translate(svgpath.translate.x, svgpath.translate.y)
        end
        
        if svgpath.matrix then
            love.graphics.applyTransform(svgpath.matrix);
        end

        if svgpath.skewx then
            love.graphics.shear(svgpath.skewx, 0);
        end
        if svgpath.skewy then
            love.graphics.shear(0, svgpath.skewy);
        end


        if svgpath.stroke_paint and svgpath.paths then
            local lw = love.graphics.getLineWidth();
            if svgpath.stroke_width then
                love.graphics.setLineWidth( svgpath.stroke_width);
            end
            love.graphics.setColor(svgpath.stroke_paint.r, svgpath.stroke_paint.g, svgpath.stroke_paint.b, svgpath.stroke_paint.a);
            -- if svgpath.paths then
       
                -- for j = 1, #svgpath.paths do                    
                --     local path = svgpath.paths[j];
                --     if #path.vertices > 2 then
                --         if path.closed then
                --             love.graphics.polygon( "line", path.vertices );
                --         else
                --             love.graphics.line(path.vertices)
                --         end
                --     end
                -- end
            -- end

            if svgpath.paths and svgpath.rendervertices and #svgpath.rendervertices > 4 then
                love.graphics.polygon("line", svgpath.rendervertices );
            end

            love.graphics.setLineWidth( lw);
        end

        if svgpath.fill_paint then
           
            love.graphics.setColor(svgpath.fill_paint.r, svgpath.fill_paint.g, svgpath.fill_paint.b, svgpath.fill_paint.a);
            if svgpath.paths and svgpath.rendervertices and #svgpath.rendervertices > 4 then
                love.graphics.polygon("fill", svgpath.rendervertices );
            end
        end


        if svgpath.childrens then
       
            Render.RenderSVGPaths(svgpath.childrens)
        end

        if first then
            love.graphics.pop();
        end

    end
end

local function apply_paint(paint)
    if paint.type == "color" then
        love.graphics.setStencilTest('notequal', 0)

        love.graphics.push()
        love.graphics.origin()
        love.graphics.setColor( paint.r,  paint.g,  paint.b,  paint.a)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
        love.graphics.pop()

        love.graphics.setStencilTest()
    end
end