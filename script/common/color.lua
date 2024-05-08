_G.LColor = {}
function LColor.new(r, g, b, a)
    local color = setmetatable({}, LColor);

    color.r = r or 255;
    color.b = b or 255;
    color.g = g or 255;
    color.a = a or 255;
    
    return color;
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

function LColor:Log(info)
    if not info then
        info = ''
    end
    info  = info .. ' Color(rgba):'
    log(info, self.r, self.g, self.b, self.a)
end

function LColor:Set(c)
    self.r = c.r;
    self.b = c.b;
    self.g = c.g;
    self.a = c.a;
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