UI.ScrollBar = {}
local UIScrollBar = UI.ScrollBar
function UIScrollBar.new( text, x, y, w, h, minv, maxv, offset )
    local sb = setmetatable({}, UI.GetMeta(UIScrollBar));

    sb.TypeObject = UIScrollBar;--must be

    sb._x = x or 0
    sb._y = y or 0
    sb._w = w or 100
    sb._h = h or 50

    sb._prex = 0

    sb._minv = minv or 0
    sb._maxv = maxv or 1
    sb._offset = offset or 0.1

    sb.circle = Circle.new(0, 0, 0, 50)
    sb.circle.mode = 'fill'
    sb.circle:SetColor(80, 80, 125, 255)

    sb.rect = Rect.new()
    sb.rect:SetColor(50, 50, 150, 255)

    sb.renderid = Render.UIScrollBarId

    if text then
        sb.text =  UI.Text.new(text, 0, 0, 0, 0)---UI.Text.new( text, x, y, w, h );
		sb.text.text = text .. " : ";
		UI.UISystem.removeUI( sb.text );

        sb.ValueText =  UI.Text.new("0", 0, 0, 0, 0)---UI.Text.new( text, x, y, w, h );
		sb.ValueText.text = tostring(minv);
		UI.UISystem.removeUI( sb.ValueText );
    end

    sb:ResetXYWH()

    UI.UISystem.addUI(sb)

    return sb
end

function UIScrollBar:ResetXYWH()
    if self.text then
        self.circle.r = self._h * 0.25
        self.circle.x = self._x
        self.circle.y = self._y + self.circle.r + self._h * 0.5
    
    
        self.rect.x = self._x
        self.rect.y = self._y + self._h * 0.125 + self._h * 0.5
    
        self.rect.w = self._w
        self.rect.h = self._h * 0.25

        self.text.x = self._x
        self.text.y = self._y

        self.text.h = self._h * 0.5

        self.text.w = self.text.ow

        self.ValueText.x = self.text.x  + self.text.w
        self.ValueText.y = self._y

        self.ValueText.h = self._h * 0.5

        self.ValueText.w = self.ValueText.ow
    else
        self.circle.r = self._h * 0.5
        self.circle.x = self._x
        self.circle.y = self._y + self.circle.r
    
    
        self.rect.x = self._x
        self.rect.y = self._y + self._h * 0.25
    
        self.rect.w = self._w
        self.rect.h = self._h * 0.5
    end
end

function UIScrollBar:draw()
    self.rect:draw()
    self.circle:draw()

    if self.text then
        self.text:draw()
        self.ValueText:draw()
    end
end

function UIScrollBar:IsInsert(x, y)
    return self.circle:CheckPointInXY(x, y)
end

function UIScrollBar:GetCurrentValue()

    local t = (self.circle.x - self._x) / self._w
    local v = math.lerp(self._minv, self._maxv, t)
    return v - v % self._offset
end


function UIScrollBar:triggerMouseDown( b, x, y )
	if self:IsInsert( x, y ) == false then
		return false;
	end

    self.IsSelect = true
    self._prex = x
	return true;
end

function UIScrollBar:triggerMouseRelease( b, x, y )
    self.IsSelect = false

	-- if self:IsInsert( x, y ) == false then
	-- 	return false;
	-- end
	-- return true;
    return false
end


function UIScrollBar:get__Value()
	return self._Value;
end

function UIScrollBar:set__Value(value)
	self:SetValue(value)

    local t = (value - self._minv) / (self._maxv - self._minv)
    t = math.clamp(t, 0, 1)

    self.circle.x = math.lerp(self._x, self._x + self._w, t)
end

function UIScrollBar:SetValue(value)
    if value == self._Value then
        return
    end
    self._Value = value;
    self.ValueText.text = tostring(value)
    self.ValueText.w = self.ValueText.ow 

    if self.ChangeEvent then
        self.ChangeEvent(self._Value)
    end
end

function UIScrollBar:triggerMouseMoved( x, y )
	if  self.IsSelect then

        local xx = math.clamp(self.circle.x + (x - self._prex ), self._x, self._x + self._w)
        
        self.circle.x = xx
        if xx == self._x or xx == self._x + self._w then
            self._prex = xx
        else
            self._prex = x
        end
        

        local v = self:GetCurrentValue()
        self:SetValue(v)
    end

    return false
end
