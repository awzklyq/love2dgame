_G.PSNRNode = {}

PSNRNode.GetMSERGB = function(img1, img2)
    local w = img1:getWidth()
    local h = img1:getHeight()

    _errorAssert(w == img2:getWidth() and h == img2:getHeight(), 'PSNRNode w h is error')

    local ER = 0
    local EG = 0
    local EB = 0
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local c1 = img1:GetPixel(i, j)
            local c2 = img2:GetPixel(i, j)

            ER = ER + (c1._r - c2._r) * (c1._r - c2._r)
            EG = EG + (c1._g - c2._g) * (c1._g - c2._g)
            EB = EB + (c1._b - c2._b) * (c1._b - c2._b)
        end
    end

    ER = ER / (w * h)
    EG = EG / (w * h)
    EB = EB / (w * h)

    return ER, EG, EB
end

PSNRNode.Process = function(img1, img2)
    local ER, EG, EB = PSNRNode.GetMSERGB(img1, img2)

    local MSEValue = (ER + EG + EB) / 3
    local Maxv = 1.0
    local v = 10 * math.log10(Maxv / MSEValue)
    return v
end
