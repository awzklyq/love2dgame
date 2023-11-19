_G.Matrixs = {}

local metatable_Matrixs = {}
metatable_Matrixs.__index = Matrixs

metatable_Matrixs.__mul = function(myvalue, value)

    if  type(value) == "table" and value.renderid == Render.MatrixsId then
        return myvalue:MulRight(value)
    elseif type(value) == "number" then
        local mat = myvalue:Copy()
        return mat:MulNumber(value)
    else
        _errorAssert(false, "metatable_Matrixs.__mul~")
    end
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

function Matrixs:SetValue(i, j, v)
    _errorAssert(i <= self.Row and j <= self.Column and tonumber(v) ~= nil, "Matrixs SetValue i <= self.Row and j <= self.Column")
    self[i][j] = v or 0
end

function Matrixs:Set(mat)
    _errorAssert(mat.Row == self.Row and mat.Column == self.Column, "Matrixs:Set i <= self.Row and j <= self.Column")
    
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
    local d = math.ArrayNorm(v1)
    local e1 = math.ArrayIdentity(v1)

    local e1d = math.ArrayMulValue(e1, d)
    local xv = math.ArraySub(v1, e1d)
    local v = math.ArrayDiv(xv, math.ArrayNorm(xv))

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

    local mat = self
    local QMat = {}
    for i = 1, math.max(self.Row, 10) do
        local R, Q = mat:HouseHolder()
        mat = R * Q
        QMat[#QMat + 1] = Q
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