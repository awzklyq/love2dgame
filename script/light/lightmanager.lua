local LightWorld = require "script/light/lib"
local lw = LightWorld({
    ambient = {55,55,55},
    refractionStrength = 32.0,
    reflectionVisibility = 0.75,
  })

_G.LightManager = {}

function _G.LightManager.load()
    --test..
    lightMouse = lw:newLight(0, 0, 255, 127, 63, 300)
	lightMouse:setGlowStrength(0.3)

	-- create shadow bodys
	circleTest = lw:newCircle(256, 256, 16)
    rectangleTest = lw:newRectangle(512, 512, 64, 64)
    
end

function _G.LightManager.update(dt)
    lw:update(dt)
    -- lw:setTranslation(100, 100, 1)
end

_G.LightManager.Need = true

function _G.LightManager.draw(func)
    lw:draw(func);
end

function LightManager.wheelmoved(x, y)
    if y > 0 then
        lw.s = lw.s *0.8;
    else
        lw.s = lw.s *1.2;
    end 
end

-- function light_world:setTranslation(l, t, s)
--     self.l, self.t, self.s = l or self.l, t or self.t, s or self.s
--   end
function LightManager.mousemoved(x, y, dx, dy, istouch)
    if love.mouse.isDown(3) then
        if lw.lights then
            for i, v in ipairs(lw.lights) do
                v.x = v.x + dx;
                v.y = v.y + dy;
            end
        end
    end
 end
