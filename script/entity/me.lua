
_G.Me = {}
_G.__setParentClass(Me, _G.Entity)
function Me.new()
    local me = setmetatable({}, {__index = Me});
    _G.__setParentObject(me, Entity);

    me.paodir = Vector.new(0, 1)
    me.speed = 0.01;

    me.tempmat = Matrix.new()

    me.noiseline = NoiseLine.new(100, 100, 300, 400, 5, 12)
    me.noiseline.visible = false

    me.ntick = 1.51
    me.ntime = 1.5

    me.noise_endpoint = nil-- 每次需要获取新的

    me.isme = true;--const
    return me;
end

function Me:init()
    self.pao = self:findBodyByName("pao");

    self.pao.h = self.pao.box.y2 - self.pao.box.y1

    self.paodian = Vector.new((self.pao.box.x1 + self.pao.box.x2) * 0.5, self.pao.box.y2)
    self.lun = self:findBodyByName("lun");
end

function Me:getPaoDianPosXY()

    return self.pao.transform:transformPoint(self.paodian.x, self.paodian.y, false, true, false)
end

function Me:getPaoDir()
    self.tempmat:reset();
    self.tempmat:rotate(self.pao.transform:getAngle())
    self.paodir.x, self.paodir.y = self.tempmat:transformPoint( 0, 1, false, true, false );
    
    --self.dir:normalize()
    return self.paodir;
end

function Me:getPosition()
    return self.lun.transform:getPosition(); 
    
end

function Me:resetNoiseLineData()
    local dir = self:getPaoDir();
    local px, py = self.lun.transform:getPositionXY()--self:getPaoDianPosXY()

    -- py = py + (self.lun.box.y2 - self.lun.box.y1) *0.5
    px = px + dir.x * self.pao.h --- (self.pao.box.x2 - self.pao.box.x1) * 0.5;
    py = py + dir.y * self.pao.h;

    self.tempmat:reset();
    self.tempmat:rotate(self.pao.transform:getAngle())
    local x2, y2 = self.tempmat:transformPoint( 0, 500, false, true, false );
    x2 = x2 +px
    y2 = y2 +py

    if not self.noise_endpoint then
        local group = _G.GroupManager.currentgroup
        if group and group.findNearestPointByLine then
            self.noise_endpoint = group:findNearestPointByLine(px, py, x2, y2)
            if  not self.noise_endpoint then
                _warn("Noise NearestPoint not find!")
                self.noise_endpoint= {x = x2, y = y2, dis = 200}
            end
        end
    end

    if self.noise_endpoint then
        x2, y2 = self.noise_endpoint.x, self.noise_endpoint.y
        self.noiseline:resetData(px, py, self.noise_endpoint.x, self.noise_endpoint.y)
    end

    self.noiseline:setMode(math.abs(y2 - py) > math.abs(x2 - px) and "x" or "y")
    self.noiseline:resetData(px, py, x2, y2)
    self.noiseline.visible = true
end

function Me:applyLinearImpulse(value)
    self.noise_endpoint = nil
    self:resetNoiseLineData()
    local dir = self:getPaoDir();
  
    self.ntick = 0

    self.lun.box2d:applyLinearImpulse(-dir.x * value, -dir.y* value)
end

function Me:update(e)
    Entity.update(self, e);

    self.ntick = self.ntick + e
    self.noiseline.visible = self.ntick <= self.ntime
    if self.noiseline.visible then
        self:resetNoiseLineData()
    end
    self.noiseline:update(e)
    if _G.isKeyDown("left", "right") then
    self.pao.transform:translate(0, -self.pao.h * 0.5)
    self.pao.transform:rotate( _G.isKeyDown("left") and self.speed or -self.speed);
    self.pao.transform:translate(0, self.pao.h * 0.5)
    end
end

function Me:draw(e)
    Entity.draw(self, e);

    self.noiseline:draw(e)
end

app.keypressed(function(key, scancode, isrepeat)
    local powerbar = _G.GroupManager.currentgroup.powerbar
    if powerbar then
        if key == "space" then
            local me = _G.getMe()
            local dir = me:getPaoDir();
            local value = powerbar:getValue()
            log("current power value: ",value)
            
            me:applyLinearImpulse(value)

        end
    end
    
end)
