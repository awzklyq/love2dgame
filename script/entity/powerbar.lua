    
_G.PowerBar = {}
function PowerBar.new(x, y, w, h, time, power)
    local pb = setmetatable({}, {__index = PowerBar});
    pb.rect = Rect.new(10, 10, 20, 80);

    pb.shader = love.graphics.newShader[[
	extern float x;
	extern float y;
	extern float w;
	extern float h;
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
	return vec4((screen_coords.x - x )/ w,(screen_coords.y - y )/h,1.0,1.0);
}
    ]]
    
    pb.x1 = x;
    pb.y1 = y + h;
    pb.x2 = x + w;
    pb.y2 = y + h;
    pb.oh = h;
    pb.h = 0
	pb.shader:send("x",pb.x1)
	pb.shader:send("y",pb.y1)
	pb.shader:send("w",w)
    pb.shader:send("h",h)
    
    pb.renderid = Render.PowerBarId

    pb.tick = 0;
    pb.time = (time or 2) + 1;

    pb.pause = false;

    pb.state = "up"

    pb.color = LColor.new(200,125,55,255)
    pb.lw = 5;

    pb.power = 20000 or power
    return pb;
end

-- 0 -- 1
function PowerBar:getValue()
    return self.tick / self.time * self.power
end

function PowerBar:update(e)
    if self.pause == false then
        if self.state == "up" then
            self.tick = self.tick + e
            if self.tick >= self.time then
                self.tick = self.time
                self.state = "down"
            end

        else
            self.tick = self.tick - e
            if self.tick <= 0 then
                self.tick = 1
                self.state = "up"
            end
        end
        self.h = self.oh * self.tick / self.time
        self.y1 = self.y2 - self.h        
    end
end

function PowerBar:draw(e)
    Render.RenderObject(self);
end