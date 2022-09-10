_G.PBRData = {}
function PBRData.new(IsUsePBR, Roughness, Metallic, F0)
    local pbr = setmetatable({}, PBRData);
    pbr.Roughness = Roughness or 1
    pbr.Metallic = Metallic or 0
    pbr.F0 = F0 or Vector3.new(0.04, 0.04, 0.04)
    pbr.IsUsePBR = IsUsePBR or false
    return pbr;
end

PBRData.IsUsePBR = function (PBR)
    return PBR and PBR.IsUsePBR
end