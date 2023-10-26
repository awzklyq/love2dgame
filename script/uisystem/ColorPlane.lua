UI.ColorPlane = {}
local ColorPlane = UI.ColorPlane
function ColorPlane.new( text, x, y, w, h)
    local cp = setmetatable({}, UI.GetMeta(ColorPlane));

    cp.TypeObject = ColorPlane;--must be

    cp._x = x or 0
    cp._y = y or 0
    cp._w = w or 30
    cp._h = h or 30

    cp.rect = Rect.new(cp._x, cp._y, cp._w, cp._h);

    cp.RColor = LColor.new(255, 0, 0)
    cp.GColor = LColor.new(0, 255, 0)
    cp.BColor = LColor.new(0, 0, 255)
    cp.AColor = LColor.new(255, 255, 255, 255)

    cp._Value = LColor.new(255, 255, 255, 255)

    local RColor_ScrollBar = UI.ScrollBar.new( 'Color R', 0, 0, 0, 0, 0, 255, 1)
    RColor_ScrollBar.Value = cp.RColor.r
    UI.UISystem.removeUI(RColor_ScrollBar)
    cp.RScoll = RColor_ScrollBar

    local GColor_ScrollBar = UI.ScrollBar.new( 'Color G', 0, 0, 0, 0, 0, 255, 1)
    GColor_ScrollBar.Value = cp.GColor.g
    UI.UISystem.removeUI(GColor_ScrollBar);
    cp.GScoll = GColor_ScrollBar

    local BColor_ScrollBar = UI.ScrollBar.new( 'Color B', 0, 0, 0, 0, 0, 255, 1)
    BColor_ScrollBar.Value = cp.BColor.g
    UI.UISystem.removeUI(BColor_ScrollBar);
    cp.BScoll = BColor_ScrollBar

    local AColor_ScrollBar = UI.ScrollBar.new( 'Color A', 0, 0, 0, 0, 0, 255, 1)
    AColor_ScrollBar.Value = cp.AColor.a
    UI.UISystem.removeUI(AColor_ScrollBar);
    cp.AScoll = AColor_ScrollBar

    AColor_ScrollBar.ChangeEvent = function(v)
        cp.AColor.a = v
        AColor_ScrollBar:SetBackgroundColor(cp.AColor)
        cp:ResetValue()
    end

    RColor_ScrollBar.ChangeEvent = function(v)
        cp.RColor.r = v
        RColor_ScrollBar:SetBackgroundColor(cp.RColor)
        cp:ResetValue()
    end

    BColor_ScrollBar.ChangeEvent = function(v)
        cp.BColor.b = v
        BColor_ScrollBar:SetBackgroundColor(cp.BColor)
        cp:ResetValue()
    end

    GColor_ScrollBar.ChangeEvent = function(v)
        cp.GColor.g = v
        GColor_ScrollBar:SetBackgroundColor(cp.GColor)
        cp:ResetValue()
    end


    cp.renderid = Render.UIColorPlaneId

    if text then
        cp.text =  UI.Text.new(text, 0, 0, 0, 0)---UI.Text.new( text, x, y, w, h );
		cp.text.text = text .. " : ";
		UI.UISystem.removeUI( cp.text );
    end

    cp:ResetXYWH()

    UI.UISystem.addUI(cp)

    log('aaaaaaaaaaaa', cp, cp.renderidr)

    return cp
end

function ColorPlane:set__Value(v)
    self.RScoll.Value = v.r
    self.GScoll.Value = v.g
    self.BScoll.Value = v.b
    self.AScoll.Value = v.a
end

function ColorPlane:get__Value()
    return self._Value
end

function ColorPlane:ResetValue()
    self._Value.r = self.RColor.r
    self._Value.g = self.GColor.g
    self._Value.b = self.BColor.b
    self._Value.a = self.AColor.a

    self.rect:SetColor(self._Value.r, self._Value.g, self._Value.b, self._Value.a)

    if self.ChangeEvent then
        self.ChangeEvent(self._Value)
    end
end

function ColorPlane:ShowPlane(show)
    self.RScoll.IsShow = show
    self.GScoll.IsShow = show
    self.BScoll.IsShow = show
    self.AScoll.IsShow = show

    if show then
        UI.UISystem.addUI( self.RScoll );
        UI.UISystem.addUI( self.GScoll );
        UI.UISystem.addUI( self.BScoll );
        UI.UISystem.addUI( self.AScoll );
    else
        UI.UISystem.removeUI( self.RScoll );
        UI.UISystem.removeUI( self.GScoll );
        UI.UISystem.removeUI( self.BScoll );
        UI.UISystem.removeUI( self.AScoll );
    end
end

function ColorPlane:ResetXYWH()

    self.rect.x = self._x
    self.rect.y = self._y
    self.rect.w = self._w
    self.rect.h = self._h

    if self.text then
        self.text.x = self.rect.x + self._w
        self.text.y = self._y

        self.text.w =  self.text.ow
        self.text.h =  self.text.oh
    end

    local sw = 120
    local sh = 50
    self.RScoll.x = self._x + self._w
    if self.text then
        self.RScoll.y = self._y + math.max(self._h, self.text.h)
    else
        self.RScoll.y = self._y + self._h
    end
   
    self.RScoll.w = sw
    self.RScoll.h = sh

    self.GScoll.x = self._x + self._w
    self.GScoll.y = self.RScoll.y + self.RScoll.h
    self.GScoll.w = sw
    self.GScoll.h = sh

    self.BScoll.x = self._x + self._w
    self.BScoll.y = self.GScoll.y + self.GScoll.h
    self.BScoll.w = sw
    self.BScoll.h = sh

    self.AScoll.x = self._x + self._w
    self.AScoll.y = self.BScoll.y + self.BScoll.h
    self.AScoll.w = sw
    self.AScoll.h = sh
end

function ColorPlane:draw()
    self.rect:draw()

    if self.text then
        self.text:draw()
    end

    -- self.RScoll:draw()
    -- self.GScoll:draw()
    -- self.BScoll:draw()
    -- self.AScoll:draw()
end

function ColorPlane:IsInsert( x, y )
    return x > self._x and x < self._x + self._w and y > self._y and y < self._y + self._h;
end

function ColorPlane:triggerMouseDown( b, x, y )
	if self:IsInsert( x, y ) == false then

        local NeedShow = false
        if UI.IsSelectUI( self.RScoll) or UI.IsSelectUI( self.GScoll) or UI.IsSelectUI( self.BScoll) or UI.IsSelectUI( self.AScoll) then
            NeedShow = true
        end

        self:ShowPlane(NeedShow)
		return false;
	end

    self:ShowPlane(true)
	return true;
end

function ColorPlane:triggerMouseRelease( b, x, y )
    --self:ShowPlane(false)
	return false
end

function ColorPlane:triggerMouseMoved( x, y )
	return false;
end
