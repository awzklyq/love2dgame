-- UI Button.
UI.Button = {}
local Button = UI.Button;
function Button.new( x, y, w, h, text, name )
	local btn = UI.CreateMetatable(Button);

	btn._x = x or 0;
	btn._y = y or 0;
	btn._w = w or 0;
	btn._h = h or 0;

	btn._name = name or "";
	
	btn.text_sw = 0.6
	btn.text_sh = 0.8
	if text ~= nil and text ~= "" then
		btn.text =  UI.Text.new(text, x, y, w * btn.text_sw, h * btn.text_sh)---UI.Text.new( text, x, y, w, h );
		btn.text:SetNormalColor(0, 0, 0, 255)
		btn.text.text = text;
		UI.UISystem.removeUI( btn.text );
	end

	btn.color1 = LColor.new(125, 125, 125);
	btn.color2 = LColor.new(150, 150, 150);
	btn.color3 = LColor.new(180, 180, 180);

	btn.color  = LColor.new(180, 180, 180);
	btn:ChangeState(UI.State_Normal)

	btn.renderType = Button.Rect;
	btn.tick = 0;

	btn:reset( );
	btn.type = "Button";
	btn.IsVisible = true
	UI.UISystem.addUI( btn );

	return btn;
end

function Button:SetNormalImage(img)
	if type(img) == 'string' then
		self.NormalImage = ImageEx.new(img)
	end

	if self.NormalImage then
		self:ResetXYWH()
	end
end

function Button:RemoveFormUISystem()
	UI.UISystem.removeUI(self);
end

function Button:set___text(text)

	if self.text then
		self.text.text = text
	end
	self:ResetXYWH()
end

function Button:get___text( hh )
	if self.text then
		return self.text.text
	end

	return ''
end

function Button:set__w(ww)

	self._w = ww;
	self:ResetXYWH()
end

function Button:set__h( hh )
	self._h = hh;

	self:ResetXYWH()
end


function Button:set__x( xx )

	if type(xx) ~= 'number' then
		return
	end

	self._x = xx

	self:ResetXYWH()
end


function Button:set__y(yy)
	if type(yy) ~= 'number' then
		return
	end

	self._y = yy

	self:ResetXYWH()
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
	if state then
		self.state = state;
	end
	
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

	self.ClickEvent = nil;
	for i, v in ipairs(UI.UISystem.buttons) do
		if  UI.UISystem.buttons[i] == self then
			
			-- UI.UISystem.buttons.splice( i, 1 );
			break;
		end
	end
		
	self:removeUI( self.text );
	self:RemoveFormUISystem()
end

function Button:ResetXYWH()
	if self.rect then
		self.rect.x = self._x
		self.rect.y = self._y
		self.rect.w = self._w
		self.rect.h = self._h
	end

	if  self.text then
		local tw = self.text_sw * self._w
		local th = self.text_sh * self._h

		local cx =  self._x + self._w * 0.5
		local cy = self._y + self._h * 0.5
		local tx = cx - tw * 0.5
		local ty = cy - th * 0.5

		self.text.x = tx
		self.text.y = ty

		self.text.w = tw
		self.text.h = th

	end

	if self.NormalImage then
		self.NormalImage.renderWidth = self._w
		self.NormalImage.renderHeight = self._h

		self.NormalImage.x = self._x
		self.NormalImage.y = self._y
	end
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
	if not self.IsVisible then
		return
	end

	if self.NormalImage then
		self.NormalImage:draw()
	else
		--normal
		if self.renderType == Button.Rect and self.rect then
			
			self.rect:SetColor( self.color );
			self.rect:draw( );
		end
	end

	if self.text and self.text.text ~= "" then
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
	if self.IsVisible == false then
		return false
	end
	if self:IsInsert( x, y ) == false then
		return false;
	end
	self:ChangeState(UI.State_Press)
	if  self.ClickEvent  then
		self:ClickEvent( );
	end

	return true;
end

function Button:triggerMouseRelease( b, x, y )
	if self.IsVisible == false then
		return false
	end

	if self:IsInsert( x, y ) == false then
		self:ChangeState(UI.State_Normal)
		return false;
	end
	self:ChangeState(UI.State_Hover)
	return true;
end

function Button:triggerMouseMoved( x, y )
	if self.IsVisible == false then
		return false
	end
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