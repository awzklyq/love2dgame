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
    _errorAssert(self.Column == mat.Row and self.Row == mat.Column, "Matrixs:Identity self.Column == self.Row")

    local ResultMat = Matrixs.new(self.Row, mat.Column )
    for i = 1, self.Row do
        for j = 1, mat.Column do
            ResultMat[i][j] = MulRowAndColumn(self, i, mat, j)
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