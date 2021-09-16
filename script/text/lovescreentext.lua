_G.LoveScreenText = {}

function LoveScreenText.new(x, y, text)-- lw :line width
    local screentext = setmetatable({}, {__index = LoveScreenText});

    screentext.x = x
    screentext.y = y

    screentext.text = text
    screentext.color = LColor.new(255,255,255,255)

    screentext.r = 0
    screentext.sx = 1
    screentext.sy = 1
    screentext.ox = 0
    screentext.oy = 0
    screentext.kx = 0 
    screentext.ky = 0

    screentext.renderid = Render.LoveScreenTextId
    return screentext;
end

function LoveScreenText:setColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
end

function LoveScreenText:draw()
    -- local r, g, b, a = love.graphics.getColor( );
    Render.RenderObject(self);
    -- love.graphics.setColor(r, g, b, a );
end