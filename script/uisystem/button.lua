-- UI Button.
UI.Button = {}
local Button = UI.Button;
function Button.new( x, y, w, h, text, name )
	local btn = setmetatable({}, UI.GetMeta(Button));

	btn.TypeObject = Button;--must be
	-- UI.UISystem.removeUI( btn );
	btn._x = x or 0;
	btn._y = y or 0;
	btn._w = w or 0;
	btn._h = h or 0;

	btn._name = name or "";
	
	if text ~= null and text ~= "" then

		btn.text = LoveScreenText.new(x, y, font, text)---UI.Text.new( text, x, y, w, h );
		btn.text.text = text;
		UI.UISystem.removeUI( btn );
	end

	btn.color1 = LColor.new(160, 160, 160);
	btn.color2 = LColor.new(125, 125, 125);
	btn.color3 = LColor.new(180, 180, 180);

	btn.color  = LColor.new(180, 180, 180);
	btn:ChangeState(UI.State_Normal)

	btn.renderType = Button.Rect;
	btn.tick = 0;

	btn:reset( );
	btn.type = "Button";
	UI.UISystem.addUI( btn );

	return btn;
end

function Button:setNormalColor(color)
	self.cololr1 = color;
end

function Button:setHoverColor(color)
	self.cololr3 = color;
end

function Button:setPressedColor(color)
	self.cololr2 = color;
end


function Button:IsPressd()
	return self.state == UI.State_Press
end

function Button:ChangeState(state)
	self.state = state;
	if self.state == UI.State_Normal then
		self.color:Set(self.color1);
	elseif self.state == UI.State_Press then
		self.color:Set(self.color2);
	elseif self.state == UI.State_Hover then
		self.color:Set(self.color3);
	end
end

-- function Button:setImage( normal, down )
-- 	if normal then
-- 		self.image1 = LImage.new( normal );
-- 	else
-- 		self.image1 = nil;
-- 	end

-- 	if down then
-- 		self.image2 = LImage.new( normal );
-- 	else
-- 		self.image2 = nil;
-- 	end
-- end

function Button:IsInsert( x, y )
	return x > self._x and x < self._x + self._w and y > self._y and y < self._y + self._h;
end

function Button:release( )
	self.polygon = nil

	self.circle = nil

	self.click = nil;
	for i, v in ipairs(UI.UISystem.buttons) do
		if  UI.UISystem.buttons[i] == self then
			
			-- UI.UISystem.buttons.splice( i, 1 );
			break;
		end
	end
		
	self:removeUI( self.text );
end

-- function Button:setRenderType( type )
-- 	self.renderType = type;
-- 	self:reset( );
-- end

function Button:reset( )
	self.polygon = nil;
	self.circle = nil; 
	self.rect = nil;

	if  self.renderType == Button.Polygon then
	
		-- self.polygon = Polygon.new( {x:self._x, y:self._y}, {x:self._w + self._x, y:self._y}, {x:self._w + self._x, y:self._h + self._y}, {x:self._x, y:self._h + self._y});
	elseif self.renderType == Button.Circle then
		-- self.circle = Circle.new( self._x, self._y, self._w * 0.5 );
	elseif self.renderType == Button.Rect then
		self.rect = Rect.new(self._x, self._y, self._w, self._h);
	end
end

function Button:draw( )
	--normal
	if self.renderType == Button.Rect and self.rect then
		
		self.rect:SetColor( self.color );
		self.rect:draw( );
	end

	if ( self.text and self.text.text ~= "" )  then
		 self.text:draw( );
	end

end

--Called from parent.
function Button:triggerResizeXY( intervalx, intervaly )

	if ( self.renderType == Button.Polygon and self.polygon ~= null ) then
		-- TODO, Only for rect.
		self.polygon:moveTo( self._x + self.w * 0.5, self._y + self.h * 0.5 );
	elseif ( self.renderType == Button.Circle and self.circle ~= null ) then
	
		self.circle:moveTo( self._x, self._y );
	end
end

function Button:triggerMouseDown( b, x, y )
	if self:IsInsert( x, y ) == false then
		return false;
	end
	self:ChangeState(UI.State_Press)
	if  self.click  then
		self:click( );
	end

	return true;
end

function Button:triggerMouseRelease( b, x, y )
	if self:IsInsert( x, y ) == false then
		self:ChangeState(UI.State_Normal)
		return false;
	end
	self:ChangeState(UI.State_Hover)
	return true;
end

function Button:triggerMouseMoved( x, y )
	if self:IsInsert( x, y ) == false then
		if self:IsPressd() then
			self:ChangeState(UI.State_Press)
		else
			self:ChangeState(UI.State_Normal)
		end
		
		return false;
	end

	self:ChangeState(UI.State_Hover)

	return true;
end


-- Button.prototype = new UIView( ); --TODO.

-- RenderType.
Button.Polygon = 1;
Button.Rect = 2;
Button.Circle = 3;