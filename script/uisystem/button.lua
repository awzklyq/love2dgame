-- UI Button.
UI.Button = {}
local Button = UI.Button;
function Button.new( x, y, w, h, text, name )
	local btn = setmetatable({},UI.GetMeta(Button));

	btn.TypeObject = Button;--must be
	UI.UISystem.removeUI( btn );
	btn._x = x or 0;
	btn._y = y or 0;
	btn._w = w or 0;
	btn._h = h or 0;

	-- 1.normal, 2.down.
	btn.state = UI.State_Normal;

	btn._name = name or "";
	-- btn.text = UI.Text.new( );
	
	if text ~= null and text ~= "" then

		btn.text._x = btn._x + btn._w * 0.5;
		btn.text._y = btn._y + btn._h * 0.5;
		btn.text._w = btn._w;
		btn.text:setFont( btn._h );
		btn.text.text = btn;
	end

	btn.color1 = LColor.new(200, 200, 200);
	btn.color2 = LColor.new(255, 255, 255);
	btn.color3 = LColor.new(255, 255, 255);

	btn.color = btn.color1;

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

function Button:changeState(state)
	if state == UI.State_Normal then
		self.color = self.color1;
	elseif state == UI.State_Pressed then
		self.color = self.color2;
	elseif state == UI.State_Hover then
		self.color = self.color3;
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

function Button:insert( x, y )
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
		-- self.circle:setColor( self.color1 );
		self.rect:draw( );
	end
	
	if self.state == UI.State_Pressed then
		self.tick = self.tick + 1;
		if (self.tick % 10 == 0  ) then
			self.state = UI.State_Normal;
			self.tick = 0;
		end
	end

	if ( self.text and self.text.text ~= "" )  then
		-- self.text:draw( );
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
	if ( self:insert( x, y ) == false ) then
		return false;
	end

	self.state = 2;
	if ( self.click ) then
		self:click( );
	end

	return true;
end


-- Button.prototype = new UIView( ); --TODO.

-- RenderType.
Button.Polygon = 1;
Button.Rect = 2;
Button.Circle = 3;