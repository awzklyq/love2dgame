_G.LColor = {}
function LColor.new(r, g, b, a)
    local color = setmetatable({}, LColor);

    color.r = r or 255;
    color.b = b or 255;
    color.g = g or 255;
    color.a = a or 255;
    
    return color;
end

function LColor.Copy(InColor)
    return LColor.new(InColor.r, InColor.g, InColor.b, InColor.a)
end

function LColor:GetShaderValue()
    return {self._r, self._g, self._b, self._a}
end

function LColor:GetMortonCodeRGB()
    local Morton = math.MortonCode3( self.r / 255 * 1023 );
    Morton = math.BitOr(Morton, math.LeftMove(math.MortonCode3( self.g / 255 * 1023) ,1));
    Morton = math.BitOr(Morton, math.LeftMove(math.MortonCode3( self.b / 255 * 1023) ,2));
    return Morton
end

function LColor:GetReverseMortonCodeRGB(x)
    self.r = math.ReverseMortonCode3( x ) / 1023 * 255;
    self.g = math.ReverseMortonCode3( math.RightMove(x, 1) ) / 1023 * 255;
    self.b = math.ReverseMortonCode3( math.RightMove(x, 2) ) / 1023 * 255;
    return self
end

function LColor:GetLuminance()
    return 0.299* self._r +  0.587 * self._g + 0.114 * self._b
end

function LColor:GetLogLuminance()
    return math.log(self:GetLuminance())
end


function LColor:Log(info)
    if not info then
        info = ''
    end
    info  = info .. ' Color(rgba):'
    log(info, self.r, self.g, self.b, self.a)
end

function LColor:Set(c, g, b, a)
    if g == nil then
        self.r = c.r;
        self.b = c.b;
        self.g = c.g;
        self.a = c.a;
    else
        self.r = c;
        self.b = g;
        self.g = b;
        self.a = a;
    end
end



LColor.__index = function(tab, key)
    if key == 'r' then
        return  rawget(tab, '_r') * 255;
    elseif key == 'g' then
        return  rawget(tab, '_g') * 255;
    elseif key == 'b' then
        return  rawget(tab, '_b') * 255;
    elseif key == 'a' then
        return  rawget(tab, '_a') * 255;
    end

    if _G["LColor"][key] then
        return _G["LColor"][key];
    end

    return rawget(tab, key);
end

LColor.__newindex = function(tab, key, value)
    if value then
        if key == 'r' then
            return rawset(tab, '_r', value / 255);
        elseif key == 'g' then
            return rawset(tab, '_g', value / 255);
        elseif key == 'b' then
            return rawset(tab, '_b', value / 255);
        elseif key == 'a' then
            return rawset(tab, '_a', value / 255);
        end
    end

    return rawset(tab, key, value);
end

LColor.__eq = function(myvalue, value)
    return myvalue._r == value._r and  myvalue._g == value._g and  myvalue._b == value._b
end

function LColor:getBrightness()
    return 0.2126 * self._r + 0.7152 * self._g + 0.0722 *self._b
end

function LColor:AdjustGray(InNewGray)
    local gray = self:GetGray()

    local scale = InNewGray / gray
    -- log('aaaaaaaa', scale, 'tttttt',  InNewGray, 'yyyyyy', gray)
    self.r = math.min(255, math.max(0, self.r * scale))
    self.g = math.min(255, math.max(0, self.g * scale))
    self.b = math.min(255, math.max(0, self.b * scale))

end

function LColor:GetGray()
    return self:GetLuminance()
end

function LColor:MulLuminance(InLum)
    self.r = math.clamp(InLum * self.r , 0, 255)
    self.g = math.clamp(InLum * self.g , 0, 255)
    self.b = math.clamp(InLum * self.b , 0, 255)

    return self
end

LColor.Red = LColor.new(255, 0, 0, 255)
LColor.Green = LColor.new(0, 255, 0, 255)
LColor.Blue = LColor.new(0, 0, 255, 255)
LColor.Black = LColor.new(0, 0, 0, 255)
LColor.Yellow = LColor.new(255, 255, 0, 255)
LColor.White = LColor.new(255, 255, 255, 255)