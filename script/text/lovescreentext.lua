_G.LoveScreenText = {}

function LoveScreenText.new(x, y, font, text)-- lw :line width
    local screentext = setmetatable({}, {__index = LoveScreenText});

    screentext.x = x
    screentext.y = y

    screentext.text = ""--love.graphics.newText( font, text )
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
    if r then
        self.color.r = r;
    end

    if g then
        self.color.g = g;
    end

    if b then
        self.color.b = b;
    end

    if a then
        self.color.a = a;
    end
end

function LoveScreenText:draw()
    -- local r, g, b, a = love.graphics.getColor( );
    Render.RenderObject(self);
    -- love.graphics.setColor(r, g, b, a );
end