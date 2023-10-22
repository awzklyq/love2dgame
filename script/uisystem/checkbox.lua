UI.CheckBox = {}
local CheckBox = UI.CheckBox
function CheckBox.new( x, y, w, h, text )
    local cb = setmetatable({}, UI.GetMeta(CheckBox));

    cb.TypeObject = CheckBox;--must be

    cb._x = x or 0
    cb._y = y or 0
    cb._w = w or 50
    cb._h = h or 50

    cb.rect1 = Rect.new()
    cb.rect1:SetColor(50, 50, 200, 255)
    cb.rect1.mode = 'line'
    cb.rect1.lw = 4
    cb.rect2 = Rect.new()
    cb.rect2:SetColor(50, 200, 200, 255)

    cb.renderid = Render.UICheckBoxId

    cb._IsSelect = false

    if text and text ~= '' then
        cb.text =  UI.Text.new(text, 0, 0, 0, 0)---UI.Text.new( text, x, y, w, h );
		cb.text.text = text .. " : ";
		UI.UISystem.removeUI( cb.text );

        cb.ValueText =  UI.Text.new("0", 0, 0, 0, 0)---UI.Text.new( text, x, y, w, h );
		cb.ValueText.text = "Closed";
		UI.UISystem.removeUI( cb.ValueText );
    end

    cb:ResetXYWH()

    UI.UISystem.addUI(cb)

    return cb
end

function CheckBox:ResetXYWH()
    self.rect1.x =  self._x
    self.rect1.y =  self._y
    self.rect1.w =  self._w
    self.rect1.h =  self._h

    local offset = self.rect1.lw
    self.rect2.x =  self.rect1.x + offset
    self.rect2.y =  self.rect1.y + offset
    self.rect2.w =  self.rect1.w - offset * 2
    self.rect2.h =  self.rect1.h - offset * 2

    if self.text then
        self.text.x = self._x + self._w + offset
        self.text.y = self._y

        self.text.w =  self.text.ow
        self.text.h =  self._h

        self.ValueText.x = self.text.x + self.text.ow 
        self.ValueText.y = self._y

        self.ValueText.w =  self.ValueText.ow
        self.ValueText.h =  self._h
    end
end

function CheckBox:IsInsert(x, y)
    return self.rect1:CheckPointInXY(x, y)
end


function CheckBox:triggerMouseDown( b, x, y )
	if self:IsInsert( x, y ) == false then
		return false;
	end

    self.IsSelect = not self.IsSelect

	return true;
end

function CheckBox:get__IsSelect()
	return self._IsSelect;
end

function CheckBox:set__IsSelect(value)
	self._IsSelect = value;
    self.ValueText.text = self._IsSelect and "Open" or "Closed";
    
    if self.ChangeEvent then
        self.ChangeEvent(self._IsSelect)
    end
end


function CheckBox:draw()
    self.rect1:draw()

    if self._IsSelect then
        self.rect2:draw()
    end

    if self.text then
        self.text:draw()
        self.ValueText:draw()
    end
end