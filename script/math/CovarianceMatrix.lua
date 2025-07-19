_G.CovarianceMatrix = {}

function CovarianceMatrix.BuildOBBFormMesh(InMesh)

    local _Verts = InMesh.verts
    local _Points = {}
    for i = 1, #_Verts do
       _Points[i] = Point3D.new(_Verts[i][1], _Verts[i][2], _Verts[i][3])
    end

    return CovarianceMatrix.BuildOBBFromPoints(_Points)
end

function CovarianceMatrix.BuildOBBFromPoints(InPoints)
     local _Verts = InPoints
    local _AveragePos = Vector3.new()
    local _N = #_Verts 
    for i = 1, _N do
        _AveragePos.x = _AveragePos.x + _Verts[i].x
        _AveragePos.y = _AveragePos.y + _Verts[i].y
        _AveragePos.z = _AveragePos.z + _Verts[i].z

    end

    _AveragePos = _AveragePos / _N

    local _Var = Vector3.new()
    local _CovXY = 0
    local _CovXZ = 0
    local _CovYZ = 0

    for i = 1, _N do
        local EX = _Verts[i].x -  _AveragePos.x
        local EY = _Verts[i].y -  _AveragePos.y
        local EZ = _Verts[i].z -  _AveragePos.z
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

    -- log(_Var.x, _Var.y, _Var.z, _CovXY, _CovXZ, _CovYZ)
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

    local _EVM, _ = _C:EigenVectors()
    local _TEVM = _EVM:Transpose()

    -- local _C_2D = _C:GetMatrix2D()
    -- local _EVM_2D = _EVM:GetMatrix2D()
    -- local _TEVM_2D = _TEVM:GetMatrix2D()

    -- local _D = _TEVM_2D * _C_2D * _EVM_2D
    -- _EVM:Log('CovarianceMatrix')
    -- log('aaaaaaa',_Var.x, _Var.y, _Var.z)
    return CovarianceMatrix.BuildOBB(InPoints, _EVM, _AveragePos)
end

function CovarianceMatrix.BuildOBB(InPoints, In_EVM, InAveragePos)
    local _Row1 = In_EVM:GetRow(1)
    local _Row2 = In_EVM:GetRow(2)
    local _Row3 = In_EVM:GetRow(3)

    local _VX = Vector3.new(_Row1[1], _Row1[2], _Row1[3])
    local _VY = Vector3.new(_Row2[1], _Row2[2], _Row2[3])

    _VY = _VY - _VX * Vector3.Dot(_VY, _VX)
    _VY:normalize()
    
    local _VZ = Vector3.cross(_VX, _VY)--Vector3.new(_Row3[1], _Row3[2], _Row3[3])
    _VZ:normalize()
    
    local _Min = Vector3.new(math.maxFloat, math.maxFloat, math.maxFloat) 
    local _Max = Vector3.new(math.minFloat, math.minFloat, math.minFloat) 
    for i = 1, #InPoints do
        local _P = InPoints[i]
        local _PJX = Vector3.Dot(_P - InAveragePos, _VX)
        local _PJY = Vector3.Dot(_P - InAveragePos, _VY)
        local _PJZ = Vector3.Dot(_P - InAveragePos, _VZ)

        local pp= _P - InAveragePos
        
        _Min.x = math.min(_Min.x, _PJX)
        _Min.y = math.min(_Min.y, _PJY)
        _Min.z = math.min(_Min.z, _PJZ)

        _Max.x = math.max(_Max.x, _PJX)
        _Max.y = math.max(_Max.y, _PJY)
        _Max.z = math.max(_Max.z, _PJZ)
    end

    local _Center = InAveragePos + (_Min + _Max) * 0.5
    local _Extent = (_Max - _Min) * 0.5
    log('OBB _Center', _Center.x, _Center.y, _Center.z)
    log('OBB _Extent', _Extent.x, _Extent.y, _Extent.z)

    return OrientedBox.BuildFromCenter_Extents_Aixs(_Center, _Extent,  _VX, _VY, _VZ)
end