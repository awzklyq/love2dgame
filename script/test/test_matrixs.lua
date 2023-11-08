math.randomseed(os.time()%10000)

local M = 5
local N = 4
local mat = Matrixs.new(M, N)
for i = 1, mat.Row do
    for j = 1, mat.Column do
        mat:SetValue(i, j, math.random(1, 100))
    end
end

mat:Log()

local matT = mat:Transpose()

matT:Log("Transpose")


local ATA = matT * mat

ATA:Log("ATA")

local MatE = Matrixs.new(N, N)
MatE:Identity()
MatE = MatE * 3
MatE:Log("MatE")

local TestMat = Matrixs.new(3, 3)
TestMat:SetValue(1, 1, 4)
TestMat:SetValue(1, 2, 2)
TestMat:SetValue(1, 3, -5)

TestMat:SetValue(2, 1, 6)
TestMat:SetValue(2, 2, 4)
TestMat:SetValue(2, 3, -9)

TestMat:SetValue(3, 1, 5)
TestMat:SetValue(3, 2, 3)
TestMat:SetValue(3, 3, -7)

local det = 4
local temp = 10
for i = 1, 4 do
    local DD = TestMat:Copy()
    DD = DD * -1

    DD[1][1] = temp + DD[1][1]
    DD[2][2] = temp + DD[2][2]
    DD[3][3] = temp + DD[3][3]

    temp = temp / 2
    log("Determinant1111", temp, DD:Determinant() )
end



