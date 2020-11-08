math.lerp = function(v1, v2, t)
    t  = math.clamp(t, 0, 1);
    return (1-t)*v1 + t *v2;
end

math.clamp = function(v, v1, v2)
    local min = math.min(v1, v2);
    local max = math.max(v1, v2);

    if v < min then
        return min;
    end

    if v > max then
        return max;
    end

    return v;
end

math.noise = function(...)
    local value = love.math.noise( ... )
    return 2 * value - 1
end

math.defaulttransform =  love.math.newTransform( );
math.MinNumber = 0.000001;
math.MaxNumber = 999999.0;
math.cEpsilon = 0.000001;
-- math.ARC = math.PI * 2;