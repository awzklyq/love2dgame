local Logic = {}


Logic.CheckRow = function(BallDatas, rect)
    local Count = 1
    local RectType = rect.RectType.Type
    local ii = rect.i
    local jj = rect.j
    
    local LeftJJ = jj
    --Left
    while LeftJJ > 1 do
        LeftJJ = LeftJJ - 1 
        local NewRect = BallDatas.RectTypes[ii][LeftJJ]
        if not NewRect then
            LeftJJ = LeftJJ + 1 
            break
        end

        if NewRect.RectType.Type ~= RectType then
            LeftJJ = LeftJJ + 1 
            break
        end

        Count = Count + 1;
    end 

    local RightJJ = jj
    --Right
    while RightJJ < #BallDatas.RectTypes[ii] do
        RightJJ = RightJJ + 1 
        local NewRect = BallDatas.RectTypes[ii][RightJJ]
        if not NewRect then
            RightJJ = RightJJ - 1
            break
        end

        if NewRect.RectType.Type ~= RectType then
            RightJJ = RightJJ - 1
            break
        end

        Count = Count + 1;
    end
    return LeftJJ, RightJJ, Count
end

Logic.CheckColumn = function(BallDatas, rect, onlydown)
    local Count = 1
    local RectType = rect.RectType.Type
    local ii = rect.i
    local jj = rect.j
    
    local LeftII = ii
    if not onlydown then
        --down
        while LeftII > 1 do
            LeftII = LeftII - 1 
            local NewRect = BallDatas.RectTypes[LeftII][jj]
            if not NewRect then
                LeftII = LeftII + 1
                break
            end

            if NewRect.RectType.Type ~= RectType then
                LeftII = LeftII + 1
                break
            end

            Count = Count + 1;
        end 
    end

    local RightII = ii
    --up
    while RightII < #BallDatas.RectTypes do
        RightII = RightII + 1 
        local NewRect = BallDatas.RectTypes[RightII][jj]
        if not NewRect then
            RightII = RightII - 1 
            break
        end

        if NewRect.RectType.Type ~= RectType then
            RightII = RightII - 1 
            break
        end

        Count = Count + 1;
    end
    return LeftII, RightII, Count
end


Logic.SetRectType = function(rect, RectType)
    rect.RectType = RectType
    local c = rect.RectType.Color
    rect:SetColor(c.r, c.g, c.b, c.a)
    rect.RectType.HelperColor = LColor.new(c.r * 0.7, c.g * 0.7, c.b * 0.7, c.a) 
end

Logic.ChangeRoleAndRect = function(CircleRole, GameRect)
    local RectType = GameRect.RectType
    Logic.SetRectType(GameRect, CircleRole.RectType)
    Logic.SetRectType(CircleRole, RectType)
end

local RemoveIIFormUpToDown = function(BallDatas, rect)
    local ii = rect.i
    local jj = rect.j
    if ii == 1 then
        BallDatas.RectTypes[1][jj] = nil
        return
    end

    for i = ii, 1, -1 do
        if i == 1 then
            BallDatas.RectTypes[i][jj] = nil
            break
        end

        local uprect = BallDatas.RectTypes[i - 1][jj]
        if uprect then
            
            BallDatas.RectTypes[i][jj] = uprect
            
            uprect.i = i
            uprect.j = jj
            uprect.x = jj * Logic.Size
            uprect.y = i * Logic.Size
            uprect:Reset()
        else
            BallDatas.RectTypes[i][jj] = nil
            break
        end
    end

end

local NeedDeletes = {}
local TestBallDatas
Logic.CheckAndRemove = function(BallDatas)
    NeedDeletes = {}
    TestBallDatas = BallDatas

    local SecondDealRects = {}
    for i = 1, #BallDatas.Rects do
        local rect =  BallDatas.Rects[i]
        if not rect.IsDelete then
            local ii = rect.i
            local jj = rect.j
            local LeftJJ, RightJJ, RCount = Logic.CheckRow(BallDatas, rect) 
            local LeftII, RightII, CCount = Logic.CheckColumn(BallDatas, rect)
            if RCount >= 3 then
                for j = LeftJJ, RightJJ do
                    BallDatas.RectTypes[ii][j].IsDelete = true
                    SecondDealRects[BallDatas.RectTypes[ii][j]] = BallDatas.RectTypes[ii][j]
                end
            end

            if CCount >= 3 then
                for j = LeftII, RightII do
                    BallDatas.RectTypes[j][jj].IsDelete = true
                    SecondDealRects[BallDatas.RectTypes[j][jj]] = BallDatas.RectTypes[j][jj]
                end
            end

            if RCount == 2 then
                local currect1 = BallDatas.RectTypes[ii][LeftJJ]
                local currect2 = BallDatas.RectTypes[ii][RightJJ]
                
                local LeftII1, RightII1, CCount1 = Logic.CheckColumn(BallDatas, currect1, true)
                local LeftII2, RightII2, CCount2 = Logic.CheckColumn(BallDatas, currect2, true)
                if CCount1 == 2 and  CCount2 == 2 then
                    currect1.IsDelete = true
                    currect2.IsDelete = true
                    BallDatas.RectTypes[ii + 1][LeftJJ].IsDelete = true
                    BallDatas.RectTypes[ii + 1][RightJJ].IsDelete = true
                end
            end


        end
    end

    for i =  #BallDatas.Rects, 1, -1 do
        local rect = BallDatas.Rects[i]
        if rect.IsDelete then
            -- table.remove(BallDatas.Rects, i)
            NeedDeletes[#NeedDeletes + 1] = rect
        end
    end

    for i, v in ipairs(NeedDeletes) do
        -- RemoveIIFormUpToDown(BallDatas, v)
        -- v:SetColor(255,255,255)
        local hc = v.RectType.HelperColor
        v:SetColor(hc.r, hc.g, hc.b, hc.a)
    end
end


local btn = UI.Button.new( 10, 30, 100, 50, 'Delete', 'btn' )

btn.ClickEvent = function()
    if not TestBallDatas then return end
    for i, v in pairs(NeedDeletes) do
        RemoveIIFormUpToDown(TestBallDatas, v)
    end

    for i =  #TestBallDatas.Rects, 1, -1 do
        local rect = TestBallDatas.Rects[i]
        if rect.IsDelete then
            table.remove(TestBallDatas.Rects, i)
        end
    end

    Logic.CheckAndRemove(TestBallDatas)
    -- local v1 = _G.BallDatas.RectTypes[6][1]
    -- local v2 = _G.BallDatas.RectTypes[7][1]
    -- local v3 = _G.BallDatas.RectTypes[8][1]
    -- RemoveIIFormUpToDown(_G.BallDatas, v1)
    -- -- RemoveIIFormUpToDown(_G.BallDatas, v2)
    -- -- RemoveIIFormUpToDown(_G.BallDatas, v3)
end

local checkb = UI.CheckBox.new( 10, 80, 20, 20, "ResetColor" )
checkb.ChangeEvent = function(Enable)
    for i, v in pairs(NeedDeletes) do
        if Enable then
            local hc = v.RectType.HelperColor
            v:SetColor(hc.r, hc.g, hc.b, hc.a)
            -- v:SetColor(255,255,255)
        else
            local c = v.RectType.Color
            v:SetColor(c.r,c.g,c.b)
        end
    end

    -- local v1 = _G.BallDatas.RectTypes[6][1]
    -- local v2 = _G.BallDatas.RectTypes[7][1]
    -- local v3 = _G.BallDatas.RectTypes[8][1]
    -- if Enable then
    --     v1:SetColor(255,255,255)
    --     v2:SetColor(255,255,255)
    --     v3:SetColor(255,255,255)
    -- else
    --     local c = v1.RectType.Color
    --     v1:SetColor(c.r,c.g,c.b)

    --     c = v2.RectType.Color
    --     v2:SetColor(c.r,c.g,c.b)

    --     c = v3.RectType.Color
    --     v3:SetColor(c.r,c.g,c.b)
    -- end
end


return Logic