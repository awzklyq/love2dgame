local vertexFormat = {
    {"VertexPosition", "float", 3},
    {"VertexTexCoord", "float", 2},
    {"VertexColor", "float", 3},--normal
    {"ConstantColor", "float", 4},
    {"ConstantColor2", "float", 2},
}

-- Use Phillips
_G.MeshWaterFFT = {}
MeshWaterFFT._Meta = {__index = MeshWaterFFT}

function MeshWaterFFT.new(InX, InY, InSize, InWinDirection, InWindSpeed, InL)
    local _mw = setmetatable({}, MeshWaterFFT._Meta)

    _mw._X = InX
    _mw._Y = InY
    _mw._Size = InSize
    _mw.transform3d = Matrix3D.new()

    --模拟区域的实际尺寸
    _mw._L = InL or 100
    _mw._WindDirection = Vector.new(1, 0)
    if InWinDirection then
        _mw._WindDirection:Set(InWinDirection)
        _mw._WindDirection:Normalize()
    end

    _mw._WindSpeed = InWindSpeed or 10.0

    _mw.A = 1.0--1e-5
    _mw.renderid = Render.MeshWaterFFTId

    _mw._Mesh = _mw:CreatWaterPlaneDatas(InX, InY, InSize, 0)

    _mw._Tick = 0
    _mw._Speed = 1.0
    _mw:InitializeFrequencyDomain()    
    return _mw
end

function MeshWaterFFT:PhillipsSpectrum2(InKX, InKY)--kx, ky, wind_dir, wind_speed, fetch
    local kx = InKX
    local ky = InKY
    local k2 = kx * kx + ky * ky
    if k2 < 1e-8 then return 0 end

    local L =  (self._WindSpeed * self._WindSpeed)  / 9.81  -- 特征波长
    local k = math.sqrt(k2)

    -- 投影到风向上（增强顺风波）
    local k_dot_w = (kx * self._WindDirection.x + ky * self._WindDirection.y) / k
    local l2 = k_dot_w * k_dot_w  -- cos²θ

    -- 避免垂直风向产生过大波（抑制 cross-wind）
    if l2 < 1e-4 then l2 = 1e-4 end

    local ph = l2 * math.exp(-1 / (k2 * L * L)) / (k2 * k2)

    -- 小尺度抑制（短风区）
    if k * self._L < 1 then
        ph = ph * k * self._L
    end

    return ph 
end

function MeshWaterFFT:PhillipsSpectrum(InKX, InKY)
    local k = math.sqrt(InKX * InKX + InKY * InKY)
    if k == 0 then return 0 end

    -- 波矢量与风向的点积
    local kDotW = (InKX * self._WindDirection.x + InKY * self._WindDirection.y) / k

    local k2 = k * k
    local k4 = k2 * k2

    --物理意义：特征波长，与最大能量波长相关
    --来源：L = V²/g，其中V是风速，g是重力加速度
    --示例：风速30m/s时，L ≈ 91.7m
    local L = (self._WindSpeed * self._WindSpeed) / 9.81

    
    -- 部分	公式	物理意义	效果
    -- 振幅系数	self.A	整体能量尺度	控制海浪整体大小
    -- 指数衰减	exp(-1/(k²L²))	抑制高频小波	L越大，允许的波长越小
    -- -4次方项	1/k⁴	Kolmogorov能量级联	符合海洋观测的能量分布
    -- 方向因子	(k·ŵ)²	风向相关性	顺风向的波能量最大
    --公式分解（标准Phillips谱）
    --P(k) = A · [exp(-1/(k²L²)) / k⁴] · (k·ŵ)² · Φ(k)
    local Test1 = k2 * L * L
    local Test2 = -1.0 / Test1
    local Test3 = math.exp(Test2)
    local Spectrum =  self.A * math.exp(-1.0 / (k2 * L * L)) / k4 * math.pow(kDotW, 2) --self.A *

    -- 抑制与风向相反的波
    if kDotW < 0 then
        Spectrum = Spectrum * 0.5
    end
 
    -- 数值阻尼 math.exp(-k2 * damping * damping)
    --目的：抑制极高频分量（极小波长）
    --物理真实：极小波受表面张力影响，不符合重力波模型
    --damping = 0.001：经验值，控制阻尼强度

    local damping = 0.001
    return Spectrum * math.exp(-k2 * damping * damping)
end

-- 生成高斯随机数
function GaussianRandom()
    local u1, u2 = 0, 0
    while u1 == 0 do u1 = math.random() end
    while u2 == 0 do u2 = math.random() end
    
    local z0 = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2)
    local z1 = math.sqrt(-2.0 * math.log(u1)) * math.sin(2.0 * math.pi * u2)
    
    -- log('aaaaaaa', z0, z1)
    return z0, z1
end

function MeshWaterFFT:InitializeFrequencyDomain()
    self._H0 = {}

    --共轭对称频域振幅，确保逆FFT得到实数值
    self._H0Conjugate = {}

    for i = 1, self._X do
        self._H0[i] = {}

        local i_conj = ((self._X - i + 1) % self._X) + 1
        self._H0Conjugate[i_conj] = {}
        for j = 1, self._Y do
            -- 波矢量 (注意: 频率空间是对称的)
            --将离散的网格坐标映射到连续的波矢量空间
            local kx = 2.0 * math.pi * (i - 1 - self._X/2) / self._L
            local ky = 2.0 * math.pi * (j - 1 - self._Y/2) / self._L

            local P = self:PhillipsSpectrum(kx, ky)
            local r1, r2 = GaussianRandom()

            -- r1 = r1 * 1000
            -- r2 = r2 * 1000
            -- P = math.random() * 1000000
            self._H0[i][j] = Complex.new(r1 * math.sqrt(P * 0.5) , r2 * math.sqrt(P * 0.5))

            -- log('ffffffff', P, kx, ky)
            --将坐标(i,j)映射到其频率反转的位置
            local j_conj = ((self._Y - j + 1) % self._Y) + 1
            self._H0Conjugate[i_conj][j_conj] = self._H0[i][j]:Conjugate()

        end
    end

    self:GenerateRenderObj()
end

-- 计算频域振幅在时间t的值
function MeshWaterFFT:CalculateHeight(InI, InJ, InT)
    local i = InI
    local j = InJ
    local t = InT

    local kx = 2.0 * math.pi * (i - 1 - self._X/2) / self._L
    local ky = 2.0 * math.pi * (j - 1 - self._Y/2) / self._L
    local k = math.sqrt(kx * kx + ky * ky)
    
    if k == 0 then
        return Complex.new(0, 0)
    end
    
    local g = 9.81

    -- 深水波色散关系
    --omega：角频率
    --使用深水波色散关系：ω² = gk，其中g=9.81 m/s²
    --对于浅水波，关系应为：ω² = gk·tanh(kh)
    local omega = math.sqrt(g * k)
    
    local h0 = self._H0[i][j]
    local h0_conj = self._H0Conjugate[i][j] or Complex.new(0, 0)
    
    local phase = omega * t
    
    local term1 = h0 * Complex.exp(phase)

    local term2  = h0_conj * Complex.exp(-phase)
    
    return term1 + term2
end


-- 使用FFT生成高度场
function MeshWaterFFT:GenerateHeightField(InT)
    local t = InT
    
    local _FFTDatas = {}
    -- 准备FFT输入数据
    for i = 1, self._X do
        _FFTDatas[i] = {}
        for j = 1, self._Y do
            _FFTDatas[i][j] = self:CalculateHeight(i, j, t)
        end
    end
    

    -- 执行逆FFT (这里使用假设的FFT库)
    -- 实际实现中需要替换为真实的FFT库调用
    local _FFT =  FourierTransform.new()
    _FFT:SetFourierDatasVectors(_FFTDatas)
    _FFT:InverseProcessTransformImage()

-- GetInverseDataFromIndex
    -- 更新高度场
    for i = 1, self._X do
        for j = 1, self._Y do
            -- 只使用实部作为高度
            local _CH =  _FFT:GetInverseDataFromIndex(i, j)
            local _H = _CH[1]:GetReal() 
            
            self._Datas[i][j][3] = _H
        end
    end
    
    -- -- 计算法线和切线
    -- self:calculateNormals()
end

function MeshWaterFFT:CreatWaterPlaneDatas(InX, InY, InSize)
    local X = InX * InSize
    local Y = InY * InSize
    local HalfX = X * 0.5
    local HalfY = Y * 0.5


    self._Datas = {}
    -- for _x = -HalfX, HalfX, InSize do
    --     local I = #self._Datas + 1
    --     self._Datas[I] = {}
    --     for _y = -HalfY, HalfY, InSize do
    --         local _Pos = Vector3.new(_x, _y, 0) 
    --         local _Nor = Vector3.new(0, 0, 1)
    --         local _UV = Vector.new((_x + HalfX) / X, (_y + HalfY) / Y)
    --         self._Datas[I][#self._Datas[I] + 1] = {_Pos.x, _Pos.y, _Pos.z, _UV.x, _UV.y, _Nor.x, _Nor.y, _Nor.z}
    --     end
    -- end

    for i = 1, InX do
        self._Datas[i] = {}
        for j = 1, InY do
            local _x = -HalfX + (i - 1) * InSize
            local _y = -HalfY + (j - 1) * InSize
            local _Pos = Vector3.new(_x, _y, 0) 
            local _Nor = Vector3.new(0, 0, 1)
            local _UV = Vector.new((_x + HalfX) / X, (_y + HalfY) / Y)
             self._Datas[i][j] = {_Pos.x, _Pos.y, _Pos.z, _UV.x, _UV.y, _Nor.x, _Nor.y, _Nor.z}
        end
    end

    self:GenerateRenderObj()
end


function MeshWaterFFT:GenerateRenderObj()
    if not self._Datas then
        return 
    end

    local Verts = {}
    for i = 1, #self._Datas - 1 do
        for j = 1, #self._Datas[1] - 1 do
            Verts[#Verts + 1] = self._Datas[i][j]
             Verts[#Verts + 1] = self._Datas[i + 1][j + 1] 
            Verts[#Verts + 1] = self._Datas[i + 1][j]

            Verts[#Verts + 1] = self._Datas[i][j]
            Verts[#Verts + 1] = self._Datas[i][j + 1] 
            Verts[#Verts + 1] = self._Datas[i + 1][j + 1]
            
        end
    end

    self.obj = love.graphics.newMesh(vertexFormat, Verts, "triangles")
end

function MeshWaterFFT:UseLights()
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


function MeshWaterFFT:SetWaterMap(InFileName)
    self._WaterMap = ImageEx.new(InFileName)
end

function MeshWaterFFT:SetSpeed(InValue)
    self._Speed = InValue or 1.0
end

function MeshWaterFFT:GetSpeed()
    return self._Speed
end

function MeshWaterFFT:update(InT)
    self._Tick = self._Tick + (InT * self._Speed)

    self:GenerateHeightField(self._Tick)

    self:GenerateRenderObj()
end

function MeshWaterFFT:draw()
    -- self._Mesh:draw()
    self.shader = Shader.GetWaterFFTShader();

    local camera3d = _G.getGlobalCamera3D()
    --modelMatrix, projectionMatrix, viewMatrix

    -- RenderSet.setNormalMap(self.normalmap)
    self:UseLights()
    self.shader:setCameraAndMatrix3D(self.transform3d, RenderSet.getUseProjectMatrix(), RenderSet.getUseViewMatrix(), camera3d.eye)

    self.shader:setWaterValue(self._WaterMap and self._WaterMap.obj or nil)

    if self.shader:hasUniform( "bcolor") and self.bcolor then
        self.shader:send('bcolor',{self.bcolor._r, self.bcolor._g, self.bcolor._b, self.bcolor._a})
    end

    -- love.graphics.setMeshCullMode("none")
    -- love.graphics.setDepthMode("less", true)

    Render.RenderObject(self)
end