local mat1 = Matrixs.new(6 ,6)
mat1:SetDatas({
    {2, 1, 1, 0, 0, 1},
    {1, 3, 0, 1, 0, 0},
    {1, 0, 4, 1, 1, 0},
    {0, 1, 1, 5, 0, 1},
    {0, 0, 1, 0, 6, 1},
    {1, 0, 0, 1, 1, 7}
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
-- mat4:FixValues()
mat4:Log('mat4')



local mat5 = mat4 * mat1
mat5:FixValues()
mat5:Log('mat5')