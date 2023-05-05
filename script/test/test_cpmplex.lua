
local Kernel0_RealX_ImY_RealZ_ImW = {
        Vector4.new(0.014096,-0.022658,0.055991,0.004413),
        Vector4.new(-0.020612,-0.025574,0.019188,0.000000),
        Vector4.new(-0.038708,0.006957,0.000000,0.049223),
        Vector4.new(-0.021449,0.040468,0.018301,0.099929),
        Vector4.new(0.013015,0.050223,0.054845,0.114689),
        Vector4.new(0.042178,0.038585,0.085769,0.097080),
        Vector4.new(0.057972,0.019812,0.102517,0.068674),
        Vector4.new(0.063647,0.005252,0.108535,0.046643),
        Vector4.new(0.064754,0.000000,0.109709,0.038697),
        Vector4.new(0.063647,0.005252,0.108535,0.046643),
        Vector4.new(0.057972,0.019812,0.102517,0.068674),
        Vector4.new(0.042178,0.038585,0.085769,0.097080),
        Vector4.new(0.013015,0.050223,0.054845,0.114689),
        Vector4.new(-0.021449,0.040468,0.018301,0.099929),
        Vector4.new(-0.038708,0.006957,0.000000,0.049223),
        Vector4.new(-0.020612,-0.025574,0.019188,0.000000),
        Vector4.new(0.014096,-0.022658,0.055991,0.004413)
}

local Kernel1_RealX_ImY_RealZ_ImW = {
        Vector4.new(0.000115,0.009116,0.000000,0.051147),
        Vector4.new(0.005324,0.013416,0.009311,0.075276),
        Vector4.new(0.013753,0.016519,0.024376,0.092685),
        Vector4.new(0.024700,0.017215,0.043940,0.096591),
        Vector4.new(0.036693,0.015064,0.065375,0.084521),
        Vector4.new(0.047976,0.010684,0.085539,0.059948),
        Vector4.new(0.057015,0.005570,0.101695,0.031254),
        Vector4.new(0.062782,0.001529,0.112002,0.008578),
        Vector4.new(0.064754,0.000000,0.115526,0.000000),
        Vector4.new(0.062782,0.001529,0.112002,0.008578),
        Vector4.new(0.057015,0.005570,0.101695,0.031254),
        Vector4.new(0.047976,0.010684,0.085539,0.059948),
        Vector4.new(0.036693,0.015064,0.065375,0.084521),
        Vector4.new(0.024700,0.017215,0.043940,0.096591),
        Vector4.new(0.013753,0.016519,0.024376,0.092685),
        Vector4.new(0.005324,0.013416,0.009311,0.075276),
        Vector4.new(0.000115,0.009116,0.000000,0.051147)
}

local Lines = {}

local cp = Complex.new(1,1)
local center = Vector.new(100,100)
local R = 350
for i = 1, 16 do
    local cp1 = cp * Complex.new(Kernel0_RealX_ImY_RealZ_ImW[i].x, Kernel0_RealX_ImY_RealZ_ImW[i].y)
    --local cp2 = cp * Complex.new(Kernel1_RealX_ImY_RealZ_ImW[i + 1].x, Kernel1_RealX_ImY_RealZ_ImW[i + 1].y)

    local cp2 = cp * Complex.new(Kernel1_RealX_ImY_RealZ_ImW[i].z, Kernel1_RealX_ImY_RealZ_ImW[i].w)

    local line = Line.new(cp1.real * R + center.x, cp1.imag * R + center.y, cp2.real * R + center.x, cp2.imag * R + center.y)
    log(cp1.real * R + center.x, cp1.imag * R + center.y, cp2.real * R + center.x, cp2.imag * R + center.y )
    Lines[#Lines + 1] = line
end

app.render(function(dt)

    for i = 1, #Lines do
        Lines[i]:draw()
    end
end)