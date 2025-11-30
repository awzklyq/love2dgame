local vertexFormat = {
    {"VertexPosition", "float", 3},
    {"VertexTexCoord", "float", 2},
    {"VertexColor", "float", 3},--normal
    {"ConstantColor", "float", 4},
    {"ConstantColor2", "float", 2},
}

_G.MeshWater = {}

function MeshWater.new(w, h, distanceOffset)
    local mesh = setmetatable({}, {__index = MeshWater});
    mesh.width = w
    mesh.height = h
    mesh.transform3d = Matrix3D.new();
    mesh.renderid = Render.MeshWaterId
    mesh.bcolor = LColor.new(255,255,255,255)
    mesh.nolight = false

    mesh.amplitude = 30
    mesh.kvalue = 4
    mesh.tvalue = 0
    mesh.speed = 1
    mesh.invWaveLength = 15

    mesh.V = 30
    mesh.A = 0.000001
    mesh.omega_hat = Vector.new(1, 1)

    mesh:createVertexs(w, h, distanceOffset)
    mesh:updateMeshObj(0)

    return mesh
end

function MeshWater:func_P_h(vec_k)
	if vec_k.x == 0 and vec_k.y == 0 then
        return 0
    end

    local g = 9.8 -- Gravitational constant
	local L = self.V*self.V / g; -- Largest possible waves arising from a continuous wind of speed V

	local k = vec_k:length();
    local k_hat = Vector.copy(vec_k)
	k_hat:normalize();

	local dot_k_hat_omega_hat = Vector.dot(k_hat, self.omega_hat);
	local result = self.A * math.exp(-1 / (k*L*k*L)) / math.pow(k, 4) * math.pow(dot_k_hat_omega_hat, 2);

    local l = 0.1
	result = result * math.exp(-k*k*l*l);  -- Eq24

	return result;
end

function MeshWater:InitPhillipsSpectrum()
    
end

function MeshWater:func_h_twiddle_0(v)--vec_k
	local xi_r = math.random(-10000 , 10000) * 0.0001
	local xi_i =  math.random(-10000 , 10000) * 0.0001
	return Complex.new(xi_r, xi_i) * math.sqrt(0.5) * math.sqrt(self:func_P_h(v));
end

function MeshWater:func_h_twiddle_0_test(v)--vec_k
	local xi_r = math.random(-10000 , 10000) * 0.0001
	local xi_i =  math.random(-10000 , 10000) * 0.0001

    local dd = Complex.new(xi_r, xi_i) * math.sqrt(0.5)
    local ddd = math.sqrt(self:func_P_h(v))
	return Complex.new(xi_r, xi_i) * math.sqrt(0.5) * math.sqrt(self:func_P_h(v));
end

function MeshWater:omega(k, g)
    return math.sqrt(g*k);
end

function MeshWater:twiddle(kn, km, twiddlev, twiddleconj, t, g)
    local k = Vector.new(kn, km):length();
    local term1 = twiddlev * Complex.exp(Complex.new(0.0, self:omega(k, g)*t));
    local term2 = twiddleconj * Complex.exp(Complex.new(0.0, -self:omega(k, g)*t));
    return term1 + term2;
end


--：https://blog.csdn.net/enjoy_pascal/article/details/81478582/
function MeshWater:FFT2(a, n, inv)

    local bit=1;
    while (math.pow(6 , bit)<n) do -- TODO
        bit = bit + 1
    end

    if not self.rev then
        self.rev = {}
        for i = 1, n do
            self.rev[i] = i
        end
    end

    for i = 1, n do
        if not self.rev.cp then 
            local j = luabit.rshift(i, 1) + 1;
            local r = luabit.rshift(self.rev[j], 1)
            self.rev[i] = luabit.band(r, luabit.lshift(luabit.band(i,1), bit-1))-- | ((i&1)<<(bit-1));
        end

        if i<self.rev[i] then
            local temp = a[i]
            a[i] = a[self.rev[i]]
            a[self.rev[i]] = a[i]
        end
    end

    self.rev.cp = true
    local mid = 1
    while mid < n do
        local temp = Complex.new(math.cos(math.pi/mid),inv*math.sin(math.pi/mid))--单位根，pi的系数2已经约掉了
        for i=1, n, mid*2 do--mid*2是准备合并序列的长度，i是合并到了哪一位
            local  omega = Complex.new(1,0);
            for j=1, mid  do--只扫左半部分，得到右半部分的答案
                if not a[i+j] or not a[i+j+mid] then
                    -- log('aaaa', mid, i, j, i+j, a[i+j], i+j+mid,  a[i+j+mid] )
                end
                if i+j+mid <= n then
                    omega= omega * temp
                    local x=a[i+j]
                    local y=omega*a[i+j+mid];
                    a[i+j]=x+y
                    a[i+j+mid]=x-y--这个就是蝴蝶变换什么的
                end
            end
        end

        mid= mid * 2
    end
end


function MeshWater:FFT(a, b, n, inv)--inv为虚部符号，inv为1时FFT，inv为-1时IFFT
    if n<= 4 then
    	return;
    end

    local A1 = {} -- mid+1
    local A2 = {} -- mid+1

    for i = 2, n, 2 do
        A1[i / 2] = a[i - 1]
        A2[i / 2] = a[i]
    end
    local mid= math.floor(n / 2);
    self:FFT(A1, b, mid,inv);--递归分治
    self:FFT(A2, b, mid,inv);

    local w0 = Complex.new(1,0)
    local wn = Complex.new(math.cos(2* math.pi/n), inv*math.sin(2* math.pi/n))

    for i = 1, mid do
        w0 = w0 * wn
        b[i] = A1[i] + w0 * A2[i]
        b[i+mid]= A1[i] - w0 * A2[i]
    end

    -- for(int i=0;i<mid;++i,w0*=wn){//合并多项式
    --     a[i]=A1[i]+w0*A2[i];
    --     a[i+mid]=A1[i]-w0*A2[i];
    -- }
end

function MeshWater:createVertexs(w, h, distanceOffset)
    self.faces = {}
    self.vertexs = {}

    local startx = -w * 0.5
    local endx = w * 0.5

    local starty = -h * 0.5
    local endy = h * 0.5

    local xx = 0
    
    local N = math.ceil(w / distanceOffset)
    local M = math.ceil(h / distanceOffset)

    self.W = w
    self.H = h

    for ix = startx, endx, distanceOffset do
        -- xx = xx + 1
        xx = math.floor((ix - startx) / distanceOffset)
        for iy = starty, endy, distanceOffset do
            -- yy = yy + 1
            local yy = math.floor((iy - starty) / distanceOffset)
            local v1 = {vertex = Vector3.new(ix, iy, 0)}
            v1.uv = Vector.new((v1.vertex.x + endx) / w, (v1.vertex.y + endy)/h)
            v1.normal = Vector3.new(xx, yy,0)

            local vv = Vector.new(2 * math.pi * (xx - N / 2) / (endx - startx), 2 * math.pi * (yy  - M / 2) / (endy - starty))
            v1.twiddle = self:func_h_twiddle_0(vv)
            v1.twiddle_conj = self:func_h_twiddle_0(vv)
            v1.twiddle_conj.imag = -v1.twiddle_conj.imag
          

            self.vertexs[#self.vertexs + 1] = v1
        end
    end

    -- local N = math.floor(w / distanceOffset)
    -- local M = math.floor(h / distanceOffset)

    for ix = 1, N -1 do
      
        for iy = 0, M - 1 do
           local v1 = self.vertexs[ix + iy * (N + 1)]
           local v2 = self.vertexs[ix + iy * (N + 1) + 1]

           local v3 = self.vertexs[ix + (iy + 1) * (N + 1) + 1]
           local v4 = self.vertexs[ix + (iy + 1) * (N + 1)]
           
            self.faces[#self.faces + 1] = {v1, v2, v3}
            self.faces[#self.faces + 1] = {v1, v3, v4}
        end
    end

    local  vv = Vector.new(2 * math.pi * (0 - N / 2) / (endx - startx), 2 * math.pi * ( 0 - M / 2) / (endy - starty))
    local oo = self:func_h_twiddle_0_test(vv)
    -- log("ccccccccc", oo.real, oo.imag)
end

function MeshWater:useLights()
    if self.nolight then
        return
    end

    local directionlights = _G.Lights.getDirectionLights()

    if #directionlights == 0 then
        return
    end

    for i = 1, #directionlights do
        local light = directionlights[i]
        if self.shader:hasUniform( "directionlight"..i) then
            self.shader:send("directionlight"..i, {light.dir.x, light.dir.y, light.dir.z, 1})
        end
        if self.shader:hasUniform( "directionlightcolor"..i) then
            self.shader:send("directionlightcolor"..i, {light.color._r, light.color._g, light.color._b, light.color._a})
        end
    end
end

function MeshWater:setWaterMap(filename)
    self.watermap = ImageEx.new(filename)
end

function MeshWater:setWaterNoiseMap(filename)
    self.waternoisemap = ImageEx.new(filename)
end

function MeshWater:update(dt)
    self.tvalue = (self.tvalue + dt * self.speed)
    self:updateMeshObj(self.tvalue)
end

function MeshWater:updateMeshObj(dt)

    local complex_hs = {}
    for i = 1, #self.vertexs do
        local v = self.vertexs[i]
        local g = 9.8 / 2--9.8
        local complex_h = self:twiddle(v.normal.x, v.normal.y, v.twiddle, v.twiddle_conj, dt, g)
        complex_hs[#complex_hs + 1] = complex_h
    end

    local b = {}
    -- self:FFT(complex_hs, b, #self.vertexs, -1)
    self:FFT2(complex_hs, #self.vertexs, -1)
    
    for i = 1, #self.vertexs do
        local sign = 1
        if i % 2 == 1 then  
            sign = -1
        end
        local v = self.vertexs[i]
        if b[i] then
            
            v.vertex.z = b[i].real * sign * 10 --b[i].real
            -- (n - N / 2) * L_x / N - sign * lambda * out_D_x[index][0],
			-- 	sign * out_height[index][0],
			-- 	(m - M / 2) * L_z / M - sign * lambda * out_D_z[index][0]0
        elseif complex_hs[i] then
            v.vertex.z = complex_hs[i].real * sign * 0.5
            -- v.vertex.z =  math.noise(v.vertex.x / (self.W * 0.05), v.vertex.y / (self.H * 0.05), dt * 2) * 50  --b[i].real
        end
    end

    local verts = {}
    for i = 1, #self.faces do
        for j = 1, 3 do
            local v = self.faces[i][j]

            local vert = {}
            vert[#vert + 1] =  v.vertex.x
            vert[#vert + 1] =  v.vertex.y
            vert[#vert + 1] =  v.vertex.z

            vert[#vert + 1] =  v.uv.x
            vert[#vert + 1] =  v.uv.y

            vert[#vert + 1] =  v.normal.x
            vert[#vert + 1] =  v.normal.y
            vert[#vert + 1] =  v.normal.z

            verts[#verts + 1] = vert
        end

    end

    self.obj = love.graphics.newMesh(vertexFormat, verts, "triangles")
end

function MeshWater:draw()
    self.shader = Shader.GetWaterShader();

    local camera3d = _G.getGlobalCamera3D()
    --modelMatrix, projectionMatrix, viewMatrix

    -- RenderSet.setNormalMap(self.normalmap)
    self:useLights()
    self.shader:setCameraAndMatrix3D(self.transform3d, RenderSet.getUseProjectMatrix(), RenderSet.getUseViewMatrix(), camera3d.eye)

    self.shader:setWaterValue(self.watermap and self.watermap.obj or nil, self.amplitude, self.kvalue, self.tvalue, self.invWaveLength, self.waternoisemap and self.waternoisemap.obj or nil)

    if self.shader:hasUniform( "bcolor") and self.bcolor then
        self.shader:send('bcolor',{self.bcolor._r, self.bcolor._g, self.bcolor._b, self.bcolor._a})
    end

    love.graphics.setMeshCullMode("none")
    love.graphics.setDepthMode("less", true)

    Render.RenderObject(self)
    -- RenderSet.setNormalMap()
end

