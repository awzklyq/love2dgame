
_G.Box2D = {}

function Box2D.new(x1,y1,x2,y2)
    local box = setmetatable({}, {__index = Box2D});
    
    x1 = x1 or 0
    y1 = y1 or 0

    x2 = x2 or 1
    y2 = y2 or 1

    box.x1 = math.min(x1, x2)
    box.y1 = math.min(y1, y2)
    box.x2 = math.max(x1, x2);
    box.y2 = math.max(y1, y2);

    box.min = Vector.new(box.x1, box.y1)
    box.max = Vector.new(box.x2, box.y2)

    box.renderid = Render.BoxBoundId;
    return box;
end

function Box2D:getBoxValueFromObj()
    assert(self.obj)
    local pos = self.obj.transform:getPosition()
   
    -- local x1, y1, x2, y2 = self.x1 + pos.x, self.y1 + pos.y, self.x2 + pos.x, self.y2 + pos.y

    local x1, y1 = self.obj.transform:transformPoint(self.x1, self.y1, false, true)
    local x2, y2 = self.obj.transform:transformPoint(self.x2, self.y2, false, true)
    return x1, y1, x2, y2
end

function Box2D:draw()
    if _G.lovedebug.showBox then
    Render.RenderObject(self)
    end
end

Box2D.Copy = function(box)
    return Box2D.new(box.x1, box.y1, box.x2, box.y2)
end