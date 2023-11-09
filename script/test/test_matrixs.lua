-- math.randomseed(os.time()%10000)

local M = 5
local N = 4
local mat = Matrixs.new(M, N)
for i = 1, mat.Row do
    for j = 1, mat.Column do
        mat:SetValue(i, j, math.random(1, 100))
    end
end

-- mat:Log()

local matT = mat:Transpose()

-- matT:Log("Transpose")


local ATA = matT * mat

-- ATA:Log('ATA')
local Eigenvalues, QT = ATA:Eigenvalues()


-- QT:Log('QT')

local str = ''
for i = 1, #Eigenvalues do
    str = str .. " " .. tostring(Eigenvalues[i])
end
-- log("Eigenvalues Number", #Eigenvalues, "TestMat:", str)
local tt = QT:GetRow(1)
local EMat = Matrixs.new(#tt, 1)
for i = 1, EMat.Row do
    EMat[i][1] = tt[i]
end

local Test1 = ATA * EMat
Test1:Log("Test1")

local Test2 = math.ArrayMulValue(tt, Eigenvalues[1])
logArray(Test2)