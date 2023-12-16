UI.Text = {}
local UIText = UI.Text
local UISystem = UI.UISystem

function UIText.new( text, x, y, w, h )
	local uitext = UI.CreateMetatable(UIText);

	uitext.type = "Text";
	uitext._x = x or 0;
	uitext._y = y or 0;
	uitext._w = w or 0;
	uitext._h = h or 0;
	uitext._text = text or "";

	uitext.color1 = LColor.new(180, 180, 180);
	uitext.color2 = LColor.new(180, 180, 180);

	uitext.color  = LColor.new(180, 180, 180);

	uitext.obj = love.graphics.newText( love.graphics.getFont(), uitext._text )

	uitext.renderid = Render.UITextId;

	uitext.lineWidth = 2;

	uitext.state = UI.State_Normal

	UISystem.addUI( uitext );

	return uitext;
end

function UIText:ChangeState(state)
	if state then
		self.state = state;
	end
	
	if self.state == UI.State_Normal then
		self.color:Set(self.color1);
	elseif self.state == UI.State_Hover then
		self.color:Set(self.color2);
	end
end

function UIText:SetNormalColor(r, g, b, a)
	if g then
		self.color1 = LColor.new(r, g, b, a);
	else
		self.color1:Set(r)
	end
	self:ChangeState()

end

function UIText:setFont( )
	
end

function UIText:get__text()
	return self._text
end

function UIText:get__ow()
	return self.obj:getWidth()
end

function UIText:get__oh()
	return self.obj:getHeight()
end

function UIText:set__text(text)
	self._text = text
	self.obj:set(text)
end


function UIText:draw( )
	Render.RenderObject(self);
end
