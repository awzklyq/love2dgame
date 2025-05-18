local mat1 = Matrixs.new(5,5)
mat1:SetDatas({
    {2, 1, 1, 0, 4},
    {1, 2, 0, 1, 7},
    {4, 0, 2, 1, 3},
    {0, 4, 1, 2, 0},
    {3, 0, -3, 7, 1}
})

mat1:Log('mat1')

-- local mat2 = Matrixs.new(4,4)
-- mat2:Identity()
-- mat2:Log('mat2')

-- local mat3 = Matrixs.ComposeColumn(mat1, mat2)
-- mat3:Log('mat3')

-- mat3:GaussJordanElimination(4)
-- mat3:Log('new mat3')

local mat4 = mat1:GetInverseByGaussJordan()
mat4:FixValues()
mat4:Log('mat4')

local mat5 = mat1 * mat4
mat5:FixValues()
mat5:Log('mat5')