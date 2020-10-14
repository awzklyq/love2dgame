_G.Box2dObject = {}

function Box2dObject.new()
    local obj = setmetatable({}, {__index = function(mytable, key, ...)
        if Box2dObject[key] then
            if type(key) == 'function' then
                return Box2dObject[key](mytable, ...)
            end

            return Box2dObject[key];
        end

        if mytable.obj and mytable.obj[key] then
            if type(key) == 'function' then
                return mytable.obj[key](mytable, ...)
            end

            return mytable.obj[key]
        end

        return nil;
      end});
    return obj;
end


function Box2dObject:newCircle(x, y, r, settings)
    local obj = Box2dObject.new()
    obj.obj = _G.box2dworld:newCircleCollider(x, y, r, settings)
    return obj
end

function Box2dObject:newRectangle(x, y, w, h, settings)
    local obj = Box2dObject.new()
    obj.obj = _G.box2dworld:newRectangleCollider(x, y, w, h, settings)
    return obj
end

function Box2dObject:newBSGRectangle(x, y, w, h, corner_cut_size, settings)
    local obj = Box2dObject.new()
    obj.obj = _G.box2dworld:newBSGRectangleCollider(x, y, w, h, corner_cut_size, settings)
    return obj
end

function Box2dObject:newPolygon(vertices, settings)
    local obj = Box2dObject.new()
    obj.obj = _G.box2dworld:newPolygonCollider(vertices, settings)
    return obj
end

function Box2dObject:newLine(x1, y1, x2, y2, settings)
    local obj = Box2dObject.new()
    obj.obj = _G.box2dworld:newLineCollider(x1, y1, x2, y2, settings)
    return obj
end

function Box2dObject:newChain(vertices, loop, settings)
    local obj = Box2dObject.new()
    obj.obj = _G.box2dworld:newChainCollider(vertices, loop, settings)
    return obj
end