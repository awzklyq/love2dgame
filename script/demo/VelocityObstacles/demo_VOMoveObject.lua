_G.DemoVOMoveObject = {}

local DemoVOMoveObjectManager = setmetatable({}, {__mode = "kv"})
--InFace 2d vector
function DemoVOMoveObject.new(x, y, r, InFace, InVelocity)
    local obj = setmetatable({}, {__index = DemoVOMoveObject});

    obj.circle = Circle.new(r, x, y)
    
    obj.circle:SetColor(0,0,255,255)
    
    obj.len = r + 50
    obj.dir = InFace

    obj.Velocity = InVelocity or 15

    obj.IsMove = false
    obj.TargePos = Vector.new(0, 0)
    obj.CurPos = Vector.new(x, y)

    obj:BuildRenderDirectionLine()

    DemoVOMoveObjectManager[#DemoVOMoveObjectManager + 1] = obj

    return obj
end

function DemoVOMoveObject:Release()
    for i = 1, #DemoVOMoveObjectManager do
        if DemoVOMoveObjectManager[i] == self then
            table.remove(DemoVOMoveObjectManager, i)
            break
        end
    end
end

function DemoVOMoveObject:BuildRenderDirectionLine()
    self.circle.x = self.CurPos.x
    self.circle.y = self.CurPos.y

    local endp = Vector.new(self.circle.x + self.dir.x * self.len, self.circle.y + self.dir.y * self.len) 
    if not  self.dirline then
        self.dirline = Line.new(self.circle.x, self.circle.y, endp.x, endp.y)
        self.dirline:SetColor(255,0,0,255)
    else
        self.dirline.x1 = self.circle.x
        self.dirline.y1 = self.circle.y

        self.dirline.x2 = endp.x
        self.dirline.y2 = endp.y
    end
end

function DemoVOMoveObject:SetX(InX)
    self.CurPos.x = InX
    self:BuildRenderDirectionLine()
end

function DemoVOMoveObject:SetY(InY)
    self.CurPos.y = InY
    self:BuildRenderDirectionLine()
end

function DemoVOMoveObject:SetXY(InX, InY)
    if not InY then
        self.CurPos.x = InX.x
        self.CurPos.y = InX.y
    else
        self.CurPos.x = InX
        self.CurPos.y = InY
    end

    self:BuildRenderDirectionLine()
end

function DemoVOMoveObject:MoveToX(InX)
    self.TargePos.x = InX

    self.IsMove = true
end

function DemoVOMoveObject:MoveToY(InY)
    self.TargePos.y = InY

    self.IsMove = true
end

function DemoVOMoveObject:MoveToXY(InX, InY)
    if not InY then
        self.TargePos.x = InX.x
        self.TargePos.y = InX.y
    else
        self.TargePos.x = InX
        self.TargePos.y = InY
    end

    self.IsMove = true
end

function DemoVOMoveObject:GetCircle()
    return self.circle
end

function DemoVOMoveObject:GetDirection()
    return self.dir
end

function DemoVOMoveObject:GetVelocity()
    return self.Velocity
end

function DemoVOMoveObject:GetPosition()
    return self.CurPos
end

function DemoVOMoveObject:GetNextFrameMoveTarget(e)
    local movedir = self.TargePos - self.CurPos
    movedir:Normalize()

    self.dir.x = movedir.x
    self.dir.y = movedir.y

    local vdis = self.Velocity * e
   

    if Vector.distance(self.TargePos, self.CurPos) > vdis then
        local MoveDis = movedir * vdis
        self.CurPos = self.CurPos + MoveDis
    else
        self.CurPos.x =  self.TargePos.x 
        self.CurPos.y =  self.TargePos.y
        self.IsMove = false
    end
   
end

function DemoVOMoveObject:GetVelocityTargetFromParame(e, InDirection, InVelocity, OutPosition)
    InDirection:Normalize()

    local vdis = InVelocity * e
   
    local TDis = Vector.distance(self.TargePos, self.CurPos)
    if TDis < vdis then
        vdis = TDis
    end

    local MoveDis = InDirection * vdis
    OutPosition:Set(self.CurPos + MoveDis)
    return OutPosition
   
end

function DemoVOMoveObject:SetDirection(InDirection)
    self.dir = Vector.copy(InDirection):Normalize()
    self:BuildRenderDirectionLine()
end

function DemoVOMoveObject:UpdateMove(e)
    self:GetNextFrameMoveTarget(e)
    self:BuildRenderDirectionLine()

end

function DemoVOMoveObject:update(e)
    if self.IsMove then
        self:UpdateMove(e)
    end
end

function DemoVOMoveObject:draw()
    self.circle:draw()
    self.dirline:draw()
end


app.update(function(dt)
    for i = 1, #DemoVOMoveObjectManager do
        if DemoVOMoveObjectManager[i] then
            DemoVOMoveObjectManager[i]:update(dt)
        end
    end
end)