_G.PerLinNoise2 = {}
local perm = {151,160,137,91,90,15,
131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,151,160,137,91,90,15,
131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180};

local fade = function( t) 
    -- Fade function as defined by Ken Perlin.  This eases coordinate values
    -- so that they will ease towards integral values.  This ends up smoothing
    -- the final output.
    return t * t * t * (t * (t * 6 - 15) + 10);         -- 6t^5 - 15t^4 + 10t^3
end

local grad = function(hash, x, y, z)
    hash = math.floor(hash) % 0xF + 1
    -- log('cccccccccc', hash)
    if hash == 0x0 then
        return  x + y
    elseif hash == 0x1 then
        return -x + y
    elseif hash == 0x2 then
        return  x - y;
    elseif hash == 0x3 then
        return -x - y;
    elseif hash == 0x4 then
        return  x + z;
    elseif hash == 0x5 then
        return -x + z;
    elseif hash == 0x6 then
        return  x - z
    elseif hash == 0x7 then
        return -x - z;
    elseif hash == 0x8 then
        return  y + z;
    elseif hash == 0x9 then
        return -y + z;
    elseif hash == 0xA then
        return  y - z;
    elseif hash == 0xB then
        return -y - z;
    elseif hash == 0xC then
        return  y + x;
    elseif hash == 0xD then
        return -y + z;
    elseif hash == 0xE then
        return  y - x;
    elseif hash == 0xF then
        return -y - z;
    else
        return 0; -- never happens
    end
end

local repeatValue = 512
local inc = function(num)
    num = num + 1
    if repeatValue > 0 then 
        local temp = num
        num = num % (repeatValue + 1);
    end
    
    return num;
end

_G.PerLinNoise2.Process = function(x, y, z)
    if repeatValue > 0  then                                    -- If we have any repeat on, change the coordinates to their "local" repetitions
        x = x % (repeatValue + 1);
        y = y % (repeatValue + 1);
        z = z % (repeatValue + 1);
    end
    
    local xi = math.floor(x) % 256 + 1--(int)x & 255;                               -- Calculate the "unit cube" that the point asked will be located in
    local yi = math.floor(y) % 256 + 1--(int)y & 255;                               -- The left bound is ( |_x_|,|_y_|,|_z_| ) and the right bound is that
    local zi = math.floor(z) % 256 + 1--(int)z & 255;                               -- plus 1.  Next we calculate the location (from 0.0 to 1.0) in that cube.
    local xf = x- math.floor(x);
    local yf = y- math.floor(y);
    local zf = z- math.floor(z);

    local u = fade(xf);
    local v = fade(yf);
    local w = fade(zf);

    local aaa, aba, aab, abb, baa, bba, bab, bbb;
    aaa = perm[perm[perm[    xi ]+    yi ]+    zi ];
    aba = perm[perm[perm[    xi ]+inc(yi)]+    zi ];
    aab = perm[perm[perm[    xi ]+    yi ]+inc(zi)];
    abb = perm[perm[perm[    xi ]+inc(yi)]+inc(zi)];
    baa = perm[perm[perm[inc(xi)]+    yi ]+    zi ];
    bba = perm[perm[perm[inc(xi)]+inc(yi)]+    zi ];
    bab = perm[perm[perm[inc(xi)]+    yi ]+inc(zi)];
    bbb = perm[perm[perm[inc(xi)]+inc(yi)]+inc(zi)];

    local x1, x2, y1, y2;
    x1 = math.lerp(    grad (aaa, xf  , yf  , zf),           -- The gradient function calculates the dot product between a pseudorandom
                grad (baa, xf-1, yf  , zf),             -- gradient vector and the vector from the input coordinate to the 8
                u);                                     -- surrounding points in its unit cube.
    x2 = math.lerp(    grad (aba, xf  , yf-1, zf),           -- This is all then lerped together as a sort of weighted average based on the faded (u,v,w)
                grad (bba, xf-1, yf-1, zf),             -- values we made earlier.
                  u);
    y1 = math.lerp(x1, x2, v);

    x1 = math.lerp(    grad (aab, xf  , yf  , zf-1),
                grad (bab, xf-1, yf  , zf-1),
                u);
    x2 = math.lerp(    grad (abb, xf  , yf-1, zf-1),
                  grad (bbb, xf-1, yf-1, zf-1),
                  u);
    y2 = math.lerp (x1, x2, v);
    
    -- log('rrrrrrr', x, y, z, y1, y2, w, (math.lerp (y1, y2, w)+1)/2)
    return (math.lerp (y1, y2, w)+1)/2; 
end