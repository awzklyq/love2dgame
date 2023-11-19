-- math.randomseed(os.time()%10000)

local M = 5
local N = 4
-- local mat = Matrixs.new(M, N)
-- for i = 1, mat.Row do
--     for j = 1, mat.Column do
--         mat:SetValue(i, j, math.random(1, 100))
--     end
-- end

-- mat:Log()

-- local matT = mat:Transpose()

-- -- matT:Log("Transpose")


-- local ATA = matT * mat

-- -- ATA:Log('ATA')
-- local Eigenvalues, QT = ATA:Eigenvalues()


-- QT:Log('QT')

-- local str = ''
-- for i = 1, #Eigenvalues do
--     str = str .. " " .. tostring(Eigenvalues[i])
-- end
-- -- log("Eigenvalues Number", #Eigenvalues, "TestMat:", str)
-- local tt = QT:GetRow(1)
-- local EMat = Matrixs.new(#tt, 1)
-- for i = 1, EMat.Row do
--     EMat[i][1] = tt[i]
-- end

-- local Test1 = ATA * EMat
-- Test1:Log("Test1")

-- local Test2 = math.ArrayMulValue(tt, Eigenvalues[1])
-- logArray(Test2)

local mat = Matrixs.new(3, 2)
mat:SetValue(1, 1, 0)
mat:SetValue(1, 2, 1)

mat:SetValue(2, 1, 1)
mat:SetValue(2, 2, 1)

mat:SetValue(3, 1, 1)
mat:SetValue(3, 2, 0)

local utest = Matrixs.new(3, 3)
utest:SetValue(1, 1, 1 / math.sqrt(6))
utest:SetValue(1, 2, 1 / math.sqrt(2))
utest:SetValue(1, 3, 1 / math.sqrt(3))

utest:SetValue(2, 1, 2 / math.sqrt(6))
utest:SetValue(2, 2, 0)
utest:SetValue(2, 3, -1 / math.sqrt(3))

utest:SetValue(3, 1,  1 / math.sqrt(6))
utest:SetValue(3, 2, - 1 / math.sqrt(2))
utest:SetValue(3, 3, 1 / math.sqrt(3))

local U, V, M = mat:GetUVMats()
-- U:Transpose():Log('aaaaaaaaaa')

-- utest:Log('utestutest')

local r = U * M * V:Transpose()

mat:Log('aaaaaaaaa')

r:Log('bbbbbbbbbb')
-- log('UUU', U.Row, U.Column)
-- log('MMM', M.Row, M.Column)
-- log('VVV', V.Row, V.Column)
-- local R = U * M * (V:Transpose())
-- R:Log('UVMats_V')

-- mat:Log("mat")

-- local UT = U:Transpose()

-- local UTU = UT * U
-- UTU:Log("UTU")

-- local VT = V:Transpose()

-- local VTV = VT * V
-- VTV:Log("VTV")
