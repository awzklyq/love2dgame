_G.Matrixs = {}

local metatable_Matrixs = {}
metatable_Matrixs.__index = Matrixs

metatable_Matrixs.__mul = function(myvalue, value)

    if  type(value) == "table" then
        if value.renderid == Render.MatrixsId then
            return myvalue:MulRight(value)
        elseif #value == myvalue.Column then
            return myvalue:MulVector(value)
        end
    elseif type(value) == "number" then
        local mat = myvalue:Copy()
        return mat:MulNumber(value)
    end

    _errorAssert(false, "metatable_Matrixs.__mul~")
end

metatable_Matrixs.__add = function(myvalue, value)
    _errorAssert(type(value) == "table" and value.renderid == Render.MatrixsId, "metatable_Matrixs.__add")
    return  Matrixs.Add(myvalue, value)
end

metatable_Matrixs.__eq = function(myvalue, value)
    _errorAssert(type(value) == "table" and value.renderid == Render.MatrixsId and myvalue.Row == value.Row and myvalue.Column == value.Column, "metatable_Matrixs.__eq")
    for i = 1, myvalue.Row do
        for j = 1, myvalue.Column do
            if myvalue[i][j] ~= value[i][j] then
                return false
            end
        end
    end

    return true
end


metatable_Matrixs.__sub = function(myvalue, value)
    _errorAssert(type(value) == "table" and value.renderid == Render.MatrixsId, "metatable_Matrixs.__sub")
    return  Matrixs.Sub(myvalue, value)
end

function Matrixs.new(row, column, v)
    local mat = setmetatable({}, metatable_Matrixs);

    for i = 1, row do
        mat[i] = {}
        for j = 1, column do
            mat[i][j] = v or 0
        end
    end

    mat.Row = row
    mat.Column = column

    mat.renderid = Render.MatrixsId
    return mat
end

function Matrixs:SetDatas(InDatas)
    for i = 1, #InDatas do
        for j = 1, #InDatas[i] do
             self[i][j] = InDatas[i][j]
        end
    end
end

function Matrixs:SetValue(i, j, v)
    _errorAssert(i <= self.Row and j <= self.Column and tonumber(v) ~= nil, "Matrixs SetValue i <= self.Row and j <= self.Column")
    self[i][j] = v or 0
end

function Matrixs:GetValue(i, j)
    _errorAssert(i <= self.Row and j <= self.Column, "Matrixs GetValue i <= self.Row and j <= self.Column")
    return self[i][j]
end

function Matrixs:Set(mat)
    _errorAssert(mat.Row <= self.Row and mat.Column <= self.Column, "Matrixs:Set i <= self.Row and j <= self.Column")
    
    for i = 1, mat.Row do
        for j = 1, mat.Column do
            self[i][j] = mat[i][j]
        end
    end
end

function Matrixs:Copy()
    local mat = Matrixs.new(self.Row, self.Column)
    for i = 1, mat.Row do
        for j = 1, mat.Column do
            mat[i][j] = self[i][j]
        end
    end

    return mat
end

function Matrixs:Transpose()
    local mat = Matrixs.new(self.Column, self.Row)

    for i = 1, self.Row do
        for j = 1, self.Column do
            mat[j][i] = self[i][j]
        end
    end

    return mat
end

function Matrixs:Identity()
    _errorAssert(self.Column == self.Row, "Matrixs:Identity self.Column == self.Row")

    for i = 1, self.Row do
        for j = 1, self.Column do
            if i == j then
                self[i][j] = 1
            else
                self[i][j] = 0
            end
        end
    end
end

function Matrixs:RemoveRow(ii)
    _errorAssert(ii >= 1 and ii <= self.Row, "Matrixs:RemoveRow")
    for i = 1, self.Row do
        if i > ii then
            for j = 1, self.Column do
                self[i - 1][j] = self[i][j]
            end
        end
    end

    table.remove(self, self.Row)
    self.Row = self.Row - 1
end

function Matrixs:RemoveColumn(jj)
    _errorAssert(jj >= 1 and jj <= self.Column, "Matrixs:RemoveRow")
    for i = 1, self.Row do
        for j = 1, self.Column do
            if j > jj then
                self[i][j - 1] = self[i][j]
            end
        end
    end

    for i = 1, self.Row do
        table.remove(self[i], self.Column)
    end

    self.Column = self.Column - 1
end

local ReCompose  = function(mat, Row, Column, ii, jj)
    _errorAssert(Row > 2 and Column > 2, "Determinant Row == Column")

    local NewMat = mat:Copy()
    NewMat:RemoveColumn(jj)
    NewMat:RemoveRow(ii)
    return NewMat
end

local Determinant
Determinant = function(mat, Row, Column)
    
    _errorAssert(Row == Column, "Determinant Row == Column")

    if Row == 2 and Column == 2 then
        return mat[1][1] * mat[2][2] -  mat[1][2] * mat[2][1]
    end

    local Result = 0
    for j = 1, Column do
        local RemMat = ReCompose(mat, mat.Row, mat.Column, 1, j)
        local k = j % 2 == 0 and 1 or -1

        Result = Result + mat[1][j] * k * Determinant(RemMat, RemMat.Row, RemMat.Column)
    end
    
    return Result
end

function Matrixs:Determinant()
    _errorAssert(self.Row == self.Column, "Determinant Row == Column")

    if self.Column == 1 and self.Row == 1 then
        return self[1][1]
    end

    return Determinant(self, self.Row, self.Column)
end

local MulRowAndColumn = function(mat1, Row, mat2, Column)
    local result = 0
    for i = 1, mat1.Column do
        result = result + mat1[Row][i] * mat2[i][Column]
    end
    return result
end

-- Not Self
function Matrixs:MulRight(mat)
    _errorAssert(self.Column == mat.Row, "Matrixs:Identity self.Column == self.Row")

    local ResultMat = Matrixs.new(self.Row, mat.Column )
    for i = 1, self.Row do
        for j = 1, mat.Column do
            ResultMat[i][j] = MulRowAndColumn(self, i, mat, j)
        end
    end
    return ResultMat
end

local function MulVectersTemp(InV1, InV2)
    _errorAssert(#InV1 == #InV2, "MulVectersTemp  #InV1 == #InV2")
    local result = 0
    for i = 1, #InV1 do
        result = result + InV1[i] * InV2[i]
    end
    return result
end

-- Return vectors 
-- InV is Column
function Matrixs:MulVector(InV)
    local Result = {}
    for i = 1, self.Row do
        local _row = self:GetRow(i)

        Result[#Result + 1] = MulVectersTemp(_row, InV)
    end

    return Result
end

function Matrixs:FindMaxAbsFromColumn(InColumn, InStartRow)
    _errorAssert(self.Column >= InColumn and InColumn >= 1 and InStartRow <= self.Row , "Matrixs.FindMaxFromColumn self.Column >= InColumn and InColumn >= 1")

    if not InStartRow then
        InStartRow = 1
    end

    local _v = self[InStartRow][InColumn]
    local _row = InStartRow
    for i = InStartRow + 1, self.Row do
        if math.abs(_v) < math.abs(self[i][InColumn]) then
            _v = self[i][InColumn]
            _row = i
        end
    end

    return _row, _v
end

function Matrixs:MulNumberByRow(InRow, InV)
     _errorAssert(self.Row >= InRow and InRow >= 1 , "Matrixs.MulNumberByRow self.Row >= InRow and InRow >= 11")
     for i = 1, self.Column do
       self[InRow][i] = self[InRow][i] * InV
    end
end

function Matrixs:DivNumberByRow(InRow, InV)
     _errorAssert(self.Row >= InRow and InRow >= 1 , "Matrixs.MulNumberByRow self.Row >= InRow and InRow >= 11")
     for i = 1, self.Column do
       self[InRow][i] = self[InRow][i] / InV
    end
end

--InRow1 = InRow1 / InV - InRow2
function Matrixs:SubAndDivByRow(InRow1, InRow2, InV)
    _errorAssert(self.Row >= InRow1 and InRow1 >= 1 and self.Row >= InRow2 and InRow2 >= 1, "Matrixs.SubRowByROw self.Row >= InRow and InRow >= 11")
    for i = 1, self.Column do
        self[InRow1][i] = self[InRow1][i] / InV - self[InRow2][i]
        if self[InRow1][i] == 0 or self[InRow1][i] == -0 then
            self[InRow1][i] = 0
        end
    end
end

function Matrixs:SwapRow(InI, InJ)
    for i = 1, self.Column do
        local temp = self[InI][i]
        self[InI][i] = self[InJ][i] 
        self[InJ][i] = temp
    end
end

function Matrixs:GaussJordanElimination(InLimitColumn)
    _errorAssert(self.Column >= InLimitColumn and InLimitColumn > 1 , "Matrixs.GaussJordanElimination self.Column >= InLimitColumn and InLimitColumn > 1")

    for j = 1, InLimitColumn do
        local _row, _v = self:FindMaxAbsFromColumn(j, j)

        if _row ~= 0 then
            self:DivNumberByRow(_row, _v)

            if j ~= _row then
                self:SwapRow(j, _row)
            end

            for i = 1, self.Row do
                if i ~= j and self[i][j] ~= 0 then
                    self:SubAndDivByRow(i, j, self[i][j])
                end
            end
        end
    end

    if self[InLimitColumn][InLimitColumn] ~= 0 then
        self:DivNumberByRow(InLimitColumn, self[InLimitColumn][InLimitColumn])
    end

     for j = 1, InLimitColumn do
        self:DivNumberByRow(j, self[j][j])
     end
end

--求解 AX = 0， X为未知向量 A为矩阵self
function Matrixs:Elimination(OutResult)
    _errorAssert(self.Column == self.Row and OutResult ~= nil)

    if self.Row == 2 then
        local _Row = self:GetRow(1)
        OutResult[2] =  _Row[1] == 0 and 0 or (-1 * _Row[2] / _Row[1])
        OutResult[1] = 1
        return 
    end

    local _NewMat = Matrixs.new(self.Row - 1, self.Column - 1)
    local _BaseRow = self:GetRow(1)
    for i = 2, self.Row do
        local _Row = self:GetRow(i)

        local _lcm = math.lcm(_BaseRow[1], _Row[1])

        local _R1 = math.ArrayMulValue(_BaseRow, _lcm / _BaseRow[1])
        local _R2 = math.ArrayMulValue(_Row, _lcm / _Row[1])
        local _Result
        if _BaseRow[1] * _Row[1] > 0 then
            _Result = math.ArraySub(_R1, _R2)
        else
            _Result = math.ArrayAdd(_R1, _R2)
        end

        for j = 2, self.Column do
            _NewMat:SetValue(i - 1, j - 1, _Result[j])
        end
    end

    _NewMat:Elimination(OutResult)


    local _RowIndex = 1
    local _Result = 0
    for i = self.Column, 2, -1 do
        _Result = _Result +_BaseRow[i] * OutResult[_RowIndex]
        _RowIndex = _RowIndex + 1
    end

    OutResult[self.Column] = _BaseRow[1] == 0 and 0 or (-1 * _Result / _BaseRow[1])

end

function Matrixs:ForeachValues(InFunc)
    for i = 1, self.Row do
        for j = 1, self.Column do
            InFunc(i, j, self[i][j])
        end
    end
end

function Matrixs:GetInverseByGaussJordan()
    _errorAssert(self.Column == self.Row , "Matrixs.GetInverseByGaussJordan self.Column == self.Row")

    local _IMat = Matrixs.new(self.Row, self.Column)
    _IMat:Identity()

    local _TempMat = Matrixs.ComposeColumn(self, _IMat)
    _TempMat:GaussJordanElimination(self.Column)

    local NewMat = Matrixs.new(self.Row, self.Column)

    local _StartColumn = self.Column
    NewMat:ForeachValues(function (InRow, InColumn, InV)
        NewMat:SetValue(InRow, InColumn, _TempMat:GetValue(InRow, InColumn + _StartColumn))
    end)

    return NewMat
end

function Matrixs:FixValues()
    self:ForeachValues(function (InRow, InColumn, InV)
        if math.abs(InV) <= math.SMALL_NUMBER then
            self[InRow][InColumn] = 0
        else
            -- log('befor', self[InRow][InColumn] )
            self[InRow][InColumn] = math.round2(self[InRow][InColumn], 10)
            -- log('after', self[InRow][InColumn] )
            -- log()
        end
    end)
end

--Compose matrixs Column
function Matrixs.ComposeColumn(mat1, mat2)
    _errorAssert(mat1.Row == mat2.Row, "Matrixs.ComposeColumn  mat1.Row == mat2.Row")
     local ResultMat = Matrixs.new(mat1.Row, mat1.Column + mat2.Column)

     ResultMat:Set(mat1)
     for i = 1, ResultMat.Row do
        for j = mat1.Column + 1, ResultMat.Column do
            ResultMat:SetValue(i, j, mat2:GetValue(i, j - mat1.Column))
        end
     end

     return ResultMat
end

-- Not Self
function Matrixs.Add(mat1, mat2)
    _errorAssert(mat1.Row == mat2.Row and mat1.Column == mat2.Column, "Matrixs.Add  mat1.Row == mat2.Row")

    local ResultMat = Matrixs.new(mat1.Row, mat1.Column )
    for i = 1, mat1.Row do
        for j = 1, mat1.Column do
            ResultMat[i][j] = mat1[i][j] + mat2[i][j]
        end
    end
    return ResultMat
end

function Matrixs.Sub(mat1, mat2)
    _errorAssert(mat1.Row == mat2.Row and mat1.Column == mat2.Column, "Matrixs.Sub  mat1.Row == mat2.Row")

    local ResultMat = Matrixs.new(mat1.Row, mat1.Column )
    for i = 1, mat1.Row do
        for j = 1, mat1.Column do
            ResultMat[i][j] = mat1[i][j] - mat2[i][j]
        end
    end
    return ResultMat
end

function Matrixs:MulNumber(v)
    for i = 1, self.Row do
        for j = 1, self.Column do
            self[i][j] = self[i][j] * v 
        end
    end
    return self
end

function Matrixs:NormRow(i)
    _errorAssert(i > self.Row, "Matrixs:NormRow i > self.Row")
    local result = 0
    for j = 1, self.Column do
        result = result + self[i][j] * self[i][j]
    end
    return math.sqrt(result)
end

function Matrixs:NormColumn(j)
    _errorAssert(j > self.Column, "Matrixs:NormColumn j > self.Column")
    local result = 0
    for i = 1, self.Row do
        result = result + self[i][j] * self[i][j]
    end
    return math.sqrt(result)
end

function Matrixs:GetColumn(j)
    local result = {}
    for i = 1, self.Row do
        result[i] = self[i][j]
    end

    return result
end

function Matrixs:GetRow(i)
    local result = {}
    for j = 1, self.Column do
        result[j] = self[i][j]
    end

    return result
end

--http://math.itdiffer.com/qr_decomposition.html
function Matrixs:HouseHolder()
    if self.Row == 1 or self.Column == 1 then
        return self:Copy()
    end

    local v1 = self:GetColumn(1)
    local d = math.ArraySize(v1)
    local e1 = math.ArrayIdentity(v1)

    local e1d = math.ArrayMulValue(e1, d)
    local xv = math.ArraySub(v1, e1d)
    local v = math.ArrayDiv(xv, math.ArraySize(xv))

    local I = Matrixs.new(self.Row, self.Column)
    I:Identity()
    local VR = math.ArrayConvertMatrixsRow(v)
    local VT = math.ArrayConvertMatrixsColumn(v)

    local H = I - VT * VR * 2.0
    local mat = H * self

    local RemoveMat = mat:Copy()
    
    RemoveMat:RemoveRow(1)
    RemoveMat:RemoveColumn(1)

    -- RemoveMat:Log("RemoveMat " .. tostring(RemoveMat.Row))

    local NewMat, H1 = RemoveMat:HouseHolder()

    if H1 then
        local NewH = Matrixs.new(mat.Row, mat.Column)
        NewH:Identity()
        for i = 1, H1.Row do
            for j = 1, H1.Column do
                NewH[i + 1][j + 1] = H1[i][j]
            end
        end

        H = H * NewH
    end
    
    -- NewMat:Log("NewMat " .. tostring(NewMat.Row))
    for i = 1, mat.Row - 1 do
        for j = 1, mat.Column - 1 do
            mat[i + 1][j + 1]= NewMat[i][j]
        end
    end

    return mat, H -- R Q
end

function Matrixs:Eigenvalues()
    _errorAssert(self.Column == self.Row, "Matrixs:Eigenvalues:  " .. tostring(self.Row) .. ' ' .. tostring(self.Column))

    local mat = self:Copy()
    local QMat = {}

    local _V = Matrixs.new(self.Row, self.Column, 0)
    for i = 1, self.Row do
        _V[i][i] = 1    
    end

    local tol = 1e-6
    for i = 1, math.max(self.Row, 250) do
        local R, Q = mat:HouseHolder()
        -- R:FixValues()
        -- Q:FixValues()
        mat = R * Q
        QMat[#QMat + 1] = Q

        _V = _V * Q
        mat:FixValues()

        -- 检查次对角元素是否收敛（简化版）
        local converged = true
        for r = 2, self.Row do
            if math.abs(mat[r][r-1]) > tol then
                converged = false
                break
            end
        end

        if converged then
           break 
        end
    end

    local QT = QMat[#QMat]:Transpose()
    for i = #QMat - 1, 1, -1 do
        QT = QT * QMat[i]:Transpose()
    end

    local Result = {}
    for i = 1, self.Row do
        Result[i] = {}
        Result[i].x = mat[i][i]
        Result[i].y = QT:GetRow(i)
    end

    table.sort(Result, function(a, b)
        return a.x > b.x
    end)

    local values = {}
    local QRMat = Matrixs.new(QT.Row, QT.Column)
   
    for i = 1, self.Row do
        values[i] = Result[i].x
        for j = 1, QRMat.Row do
            QRMat:SetValue(j, i, Result[i].y[j])
        end
    end

    return values, QRMat
end
Matrixs.EigenValues = Matrixs.Eigenvalues 

function Matrixs:EigenVectors()
    _errorAssert(self.Column == self.Row, "Matrixs:EigenVectors:  " .. tostring(self.Row) .. ' ' .. tostring(self.Column))

    local _EigenValues, _ = self:EigenValues()

    -- table.sort(_EigenValues, function(a, b)
    --     return b > a
    -- end)
    local _NewMat = Matrixs.new(self.Row, self.Column)
    for i = 1, #_EigenValues do
        local VS = self:EigenVectorFormValue(_EigenValues[i])
        for j = 1, self.Column do
            _NewMat:SetValue(i, j, VS[j])
        end
    end

    return _NewMat
end

function Matrixs:EigenVectorFormValue(InValue)
    _errorAssert(self.Column == self.Row, "Matrixs:EigenVectorFormValue:  " .. tostring(self.Row) .. ' ' .. tostring(self.Column))
    -- local _Temp = self:Copy()
    local _NewMat = Matrixs.new(self.Row, self.Column, 0)
    for i = 1, self.Row do
        _NewMat:SetValue(i, i, InValue)
    end

    _NewMat = self - _NewMat
    
    local _OutResult = {}
    _NewMat:Elimination(_OutResult)

    local reverse = {}
    for i = #_OutResult, 1, -1 do
        reverse[#reverse + 1] = _OutResult[i]
    end

    return math.ArrayNormalize(reverse)
end

function Matrixs:GetUVMats()
    local A = self:Copy()
    local AT = A:Transpose()
    local ATA = AT * A
    local V_Eigenvalues, V = ATA:Eigenvalues()

    local AAT = A * AT

    local U_Eigenvalues, U = AAT:Eigenvalues()

    local n = #V_Eigenvalues
    local MZ = Matrixs.new(U.Row,  V.Column)
    for i = 1, n do
        MZ[i][i] = math.sqrt(V_Eigenvalues[i])
    end

    return U, V, MZ
end

function Matrixs:GetMaxValue()
    local _MaxV = self[1][1]
    for i = 1, self.Row do
        for j = 1, self.Column do
            _MaxV = math.max(_MaxV, self[i][j])
        end
    end

    return _MaxV
end

function Matrixs:GenerateDrawGrayDatas(x, y, w, h)
    local _MaxV = self:GetMaxValue()
    self._DrawGrayDatas = {}

    local StartX = x
    local StartY = y

    local NeedW = w / self.Row
    local NeedH = h / self.Column

    local RW = NeedW - 2
    local RH = NeedH - 2
    for i = 1, self.Row do
        self._DrawGrayDatas[i] = {}
        for j = 1, self.Column do
            local r = Rect.new(StartX + (i - 1) * NeedW + 1, StartY + (j - 1) * NeedH + 1, RW, RH)

            local gray = (self[i][j] / _MaxV) * 255
            r:SetColor(gray, gray, gray, 255)

            self._DrawGrayDatas[i][j] = r
        end
    end
end

function Matrixs:DrawGrayDatas()
    if not self._DrawGrayDatas or #self._DrawGrayDatas == 0 then return end

    for i = 1, self.Row do
        for j = 1, self.Column do
            self._DrawGrayDatas[i][j]:draw()
        end
    end
end

function Matrixs:GetDrawGrayDatas()
    return self._DrawGrayDatas
end

function Matrixs:GetMatrix2D()
    _errorAssert(self.Row == 3 and self.Column == 3)

    local _m = Matrix2D.new()
    for i = 1,  3 do
        for j = 1, 3 do
            _m:SetValue(i, j, self:GetValue(i, j))
        end
    end

    return _m
end


function Matrixs:Log(info)
    local str = "Matrixs "
    if info ~= nil then
        str = str.. tostring(info)
    end
    str = str .. " : \n" 

    for i = 1, self.Row do
        str = str .. 'Row ' .. tostring(i) .. ' : '
        for j = 1, self.Column do
            str = str .. tostring(self[i][j]) .. " "
        end
        str = str .. '\n'
    end

    log(str)
end