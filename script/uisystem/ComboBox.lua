UI.ComboBox = {}
local ComboBox = UI.ComboBox;

local Button = UI.Button
--Values: {value1, value2}
function ComboBox.new( x, y, w, h, Values)
    local cb = UI.CreateMetatable(ComboBox);

    w = w or 0
    x = x or 0
    cb._w2 = math.min(w * 0.2, 40)
    cb._x2 = x + w - cb._w2

    cb._x = x or 0
    cb._y = y or 0
    cb._w =  cb._x2 - x
    cb._h = h or 0
    cb.Values = Values or {}
   
    cb._Value = ""
    cb.RenderObj = {}

    cb._IsSelect = false

    cb:Reset()

    UI.UISystem.addUI( cb );

    return cb
end

function ComboBox:Reset()
    self._IsSelect = false

    for i = 1, #self.RenderObj do
        self.RenderObj:release()
    end

    self.RenderObj = {}

    if #self.Values > 0 then
        for i = 1, #self.Values do
            local btn = Button.new( self._x, self._y + self._h * (i - 1), self._w, self._h, self.Values[i], "ComboBox" )
            btn.IsVisible = i == 1
            
            btn._Value = self.Values[i]
            self.RenderObj[#self.RenderObj + 1] = btn

            btn:RemoveFormUISystem()
        end
    else
        local IsVisible = true
        for i, v in pairs(self.Values) do
            local btn = Button.new( self._x, self._y + self._h * (i - 1), self._w, self._h, i, "ComboBox" )
            btn.IsVisible = IsVisible
            IsVisible = false
            btn._Value = v
            self.RenderObj[#self.RenderObj + 1] = btn

            btn:RemoveFormUISystem()
        end
    end

    if self.SelectBtn then
        self.SelectBtn:release()
    end

    self.SelectBtn = Button.new( self._x2, self._y, self._w2, self._h, i, "ComboBox" )
    self.SelectBtn:SetNormalImage("SJ1.png")
    self.SelectBtn:RemoveFormUISystem()

    local cb = self
    self.SelectBtn.ClickEvent = function()
        cb.IsSelect = not cb.IsSelect
    end

    for i = 1, #self.RenderObj do
        if i == 1 then
            self._Value =  self.RenderObj[i]._Value
        end
        self.RenderObj[i].SelectIndex = i
        self.RenderObj[i]:ResetXYWH()
        self.RenderObj[i].ClickEvent = function()
            cb.IsSelect = not cb.IsSelect
            if cb.IsSelect == false then
                if cb.ChangeEvent then
                    cb.ChangeEvent(cb.RenderObj[i]._Value)
                end

                cb:ChangeTextAndValue(cb.RenderObj[i].SelectIndex)
            end
        end
    end
end

function ComboBox:ChangeTextAndValue(SelectIndex)
    if #self.RenderObj < 2 or SelectIndex > #self.RenderObj  then
        return
    end

    local sv = self.RenderObj[SelectIndex]._Value
    local st = self.RenderObj[SelectIndex]._text

    for i = SelectIndex, 2, -1 do
        self.RenderObj[i]._Value = self.RenderObj[i - 1]._Value
        self.RenderObj[i]._text = self.RenderObj[i - 1]._text
    end

    self.RenderObj[1]._Value = sv
    self.RenderObj[1]._text = st
end

function ComboBox:triggerSelectEvent()
    if self._IsSelect then
        self.SelectBtn:SetNormalImage("SJ1.png")
    else
        self.SelectBtn:SetNormalImage("SJ2.png")
    end

    -- if self._IsSelect then
        for i = 1, #self.RenderObj do
            if i ~= 1 then
                self.RenderObj[i].IsVisible = self._IsSelect
            end
        end
    -- end
end

function ComboBox:get__IsSelect()
	return self._IsSelect;
end

function ComboBox:set__IsSelect(value)
	self._IsSelect = value;
    
    self:triggerSelectEvent()
end

function ComboBox:get__Value()
	return self._Value;
end

function ComboBox:set__Value(value)
    local IsSelectIndex = 0
    for i = 1, #self.RenderObj do
        if value == self.RenderObj[i]._Value then
            IsSelectIndex = i
            break
        end
    end

    if IsSelectIndex > 0 then
        self:ChangeTextAndValue(IsSelectIndex)
        self._Value = value;
    end
end


function ComboBox:triggerMouseRelease( b, x, y )
    -- self.IsSelect = false

	-- if self:IsInsert( x, y ) == false then
	-- 	return false;
	-- end
	-- return true;
    return false
end


function ComboBox:triggerMouseDown( b, x, y )
	-- if self:IsInsert( x, y ) == false then
	-- 	return false;
	-- end
    if self.SelectBtn:triggerMouseDown(b, x, y) then
        return true
    end

    for i = 1, #self.RenderObj do
        if self.RenderObj[i].IsVisible and self.RenderObj[i]:triggerMouseDown(b, x, y)  then
            return true
        end
    end

    self.IsSelect = false
    -- return false

    -- if self.IsSelect  then
    -- else
    --     self.IsSelect = true
    -- end
	return false;
end

function ComboBox:draw()
    for i = 1, #self.RenderObj do
        self.RenderObj[i]:draw()
    end

    self.SelectBtn:draw()
end