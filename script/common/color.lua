_G.LColor = {}
function LColor.new(r, g, b, a)
    local color = setmetatable({}, LColor);

    color.r = r;
    color.b = b;
    color.g = g;
    color.a = a;
    
    return color;
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

    return rawget(tab, key);
end

LColor.__newindex = function(tab, key, value)
    if value then
        if key == 'r' then
            rawset(tab, '_r', value / 255);
        elseif key == 'g' then
            rawset(tab, '_g', value / 255);
        elseif key == 'b' then
            rawset(tab, '_b', value / 255);
        elseif key == 'a' then
            rawset(tab, '_a', value / 255);
        end
    end

    rawset(tab, key, value);
end