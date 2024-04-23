-- 计算二维高斯函数的值
function gaussian(x, y, sigma)
    local coefficient = 1 / (2 * math.pi * sigma * sigma)
    local exponent = -(x*x + y*y) / (2 * sigma * sigma)
    return coefficient * math.exp(exponent)
end

-- 生成3x3的高斯权重核
function generateGaussianKernel3x3(sigma)
    local kernel = {}
    local sum = 0.0  -- 用于归一化

    -- 遍历核内所有位置
    for i = -1, 1 do
        local row = {}
        for j = -1, 1 do
            -- 计算当前位置的权重
            local weight = gaussian(i, j, sigma)
            table.insert(row, weight)
            -- 累加权重值
            sum = sum + weight
        end
        table.insert(kernel, row)
    end

    -- 归一化权重值，使它们的和为1
    for i = 1, #kernel do
        for j = 1, #kernel[i] do
            kernel[i][j] = kernel[i][j] / sum
        end
    end

    return kernel
end

-- 打印核的权重值
function printKernel(kernel)
    for i = 1, #kernel do
        for j = 1, #kernel[i] do
            io.write(string.format("%.5f ,", kernel[i][j]))
        end
        io.write("\n")
    end
end

-- 生成3x3的高斯核
local sigma = 0.1
local gaussianKernel = generateGaussianKernel3x3(sigma)

-- 打印核的权重值
printKernel(gaussianKernel)
