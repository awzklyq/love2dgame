_G.CovarianceMatrix = {}

function CovarianceMatrix.BuildCovarianceMatrix(InMesh)

    local _Verts = InMesh.verts
    local _AveragePos = Vector3.new()
    local _N = #_Verts 
    for i = 1, _N do
        _AveragePos.x = _AveragePos.x + _Verts[i][1]
        _AveragePos.y = _AveragePos.y + _Verts[i][2]
        _AveragePos.z = _AveragePos.z + _Verts[i][3]

    end

    _AveragePos = _AveragePos / _N

    local _Var = Vector3.new()
    local _CovXY = 0
    local _CovXZ = 0
    local _CovYZ = 0

    for i = 1, _N do
        local EX = _Verts[i][1] -  _AveragePos.x
        local EY = _Verts[i][2] -  _AveragePos.y
        local EZ = _Verts[i][3] -  _AveragePos.z
        _Var.x = _Var.x + EX * EX
        _Var.y = _Var.y + EY * EY
        _Var.z = _Var.z + EZ * EZ

        _CovXY = _CovXY + EX * EY
        _CovXZ = _CovXZ + EX * EZ
        _CovYZ = _CovYZ + EY * EZ
    end

    _Var = _Var / (_N - 1)
    _CovXY = _CovXY / (_N - 1)
    _CovXZ = _CovXZ / (_N - 1)
    _CovYZ = _CovYZ / (_N - 1)

    log(_Var.x, _Var.y, _Var.z, _CovXY, _CovXZ, _CovYZ)
    local _C = Matrixs.new(3, 3)
    _C:SetValue(1, 1, _Var.x)
    _C:SetValue(1, 2, _CovXY)
    _C:SetValue(1, 3, _CovXZ)

    _C:SetValue(2, 1, _CovXY)
    _C:SetValue(2, 2, _Var.y)
    _C:SetValue(2, 3, _CovYZ)

    _C:SetValue(3, 1, _CovXZ)
    _C:SetValue(3, 2, _CovYZ)
    _C:SetValue(3, 3, _Var.z)

    local _EVs, _ = _C:Eigenvalues()
end