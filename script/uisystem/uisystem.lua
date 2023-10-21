_G.UI = {}

UI.State_Normal = 1;
UI.State_Press = 2;
UI.State_Hover = 3;

UI.UISystem = {};

dofile('script/uisystem/button.lua')
dofile('script/uisystem/text.lua')

local UISystem = UI.UISystem;
UISystem.buttons = {};

UISystem.textinputs ={};

UISystem.texts = {};

UISystem.textareas = {};

UISystem.uiviews = {};

UISystem.fouseuis = {};

UISystem.uilists = {};

UISystem.swfs = {};

UISystem.removeUI = function( ui )
	if ( UISystem.isButton( ui )	) then
		UISystem.buttons.remove( ui );
	elseif ( UISystem.isText( ui ) ) then
		UISystem.texts.remove( ui );
	elseif ( UISystem.isTextArea( ui ) ) then
		UISystem.textareas.remove( ui );
	elseif ( UISystem.isTextInput( ui ) ) then
		UISystem.textinputs.remove( ui );
	elseif ( UISystem.isUIView( ui ) ) then
		UISystem.uiviews.remove( ui );
	elseif ( UISystem.isUIList( ui ) ) then
		UISystem.uilists.remove( ui );
	end
end

UISystem.addUI = function( ui )
	if ( UISystem.isButton( ui )) then
		table.insert( UISystem.buttons, ui);
	elseif ( UISystem.isText( ui ) ) then
		table.insert( UISystem.texts, ui);
	elseif ( UISystem.isTextArea( ui ) ) then
		table.insert( UISystem.textareas, ui);
	elseif ( UISystem.isTextInput( ui ) ) then
		table.insert( UISystem.textinputs, ui);
	elseif ( UISystem.isUIView( ui ) ) then
		table.insert( UISystem.uiviews, ui);
	elseif ( UISystem.isUIList( ui ) ) then
		table.insert( UISystem.uilists, ui);
	end
end

UISystem.render = function( e )
	for i, v in ipairs(UISystem.buttons) do
		v:draw(e);
	end

	for i, v in ipairs(UISystem.texts) do
		v:draw(e);
	end

	for i, v in ipairs(UISystem.uiviews) do
		v:draw(e);
	end
end

_G.app.render(function(e)
    UISystem.render(e) 
end)

UISystem.isButton = function( obj )
	return obj and obj.type and obj.type == "Button";
end

UISystem.isText = function( obj )
	return obj.type == "Text";
end

UISystem.isTextArea = function( obj )
	return obj and obj.type and obj.type == "TextArea";
end

UISystem.isTextInput = function( obj )
	return obj and obj.type and obj.type == "TextInput";
end

UISystem.isUIList = function( obj )
	return obj and obj.type and obj.type == "UIList";
end

UISystem.isUIView = function( obj, isview )

	if ( isview == true ) then
		if ( obj.type == "UIView" ) then
			return;
		end
	end

	return ( obj.type == "UIView" ) or UISystem.isButton( obj ) or UISystem.isText( obj ) or UISystem.isTextArea( obj ) or UISystem.isTextInput( obj );
end

UI.get__x = function( self )
	if ( self._parent ~= nil ) then
		return self._x - self._parent._x;
	end
	return self._x;
end

UI.set__x = function( self, xx )
	if type(xx) ~= 'number' then
		return
	end

	local  oldx = self._x;
	if ( self._parent ~= nil ) then
		self._x = self._parent._x + xx;
	else
		self._x = xx;
	end

	if ( self.elements ) then
	
		local  temp = self.elements;
		local  intervalx = self._x - oldx;
		for i, v in ipairs(temp) do
		
			temp[i].x = temp[i].x +  intervalx;
			if ( temp[i].triggerResizeXY ~= nil and Global.isFunction( temp[i].triggerResizeXY ) ) then
				temp[i].triggerResizeXY( intervalx, 0 );
			end
		end
	end
end


UI.get__y = function(self)
	if ( self._parent ~= nil ) then
		return self._y - self._parent._y;
	end

	return self._y;
end
UI.set__y = function(self, yy)
	if type(yy) ~= 'number' then
		return
	end

	local  oldy = self._y;
	if ( self._parent ~= nil ) then
		self._y = self._parent._y + yy;
	else
		self._y = yy;
	end

	if ( self.elements ) then
		local  temp = self.elements;
		local  intervaly = self._y - oldy;
		for i = 1, #temp, 1 do
		
			temp[i].y = temp[i].y + intervaly;

			if ( temp[i].triggerResizeXY ~= nil and Global.isFunction( temp[i].triggerResizeXY ) ) then
				temp[i].triggerResizeXY( 0, intervaly );
			end
		
		end
	end
end

UI.get__w = function(self)
	return self._w;
end

UI.set__w = function(self, ww)

	self._w = ww;
end

UI.get__h = function( )
	return self._h;
end
UI.set__y = function( hh )
	self._h = hh;
end

UI.get__name = function( )
	return self._name;
end

UI.set__name = function( uiname )

	if ( self._parent ~= nil ) then	
		if ( self._parent[uiname] ~= nil ) then
			log.warn( "The ui name is used ！");
			return
		end

		if ( self._parent[self._name] ~= nil ) then
			self._parent[self._name] = nil
		end
	end

	self._name = uiname;

	if ( self._parent ~= nil ) then
		self._parent[self._name] = self;
	end
end

function UIBase__index(tab, key, ...)
	if UI['get__'..key] then
		return UI['get__'..key](tab);
	end
	
	local TypeObject = rawget(tab, "TypeObject");
	if TypeObject and TypeObject[key] then
		return TypeObject[key];
	end

	return rawget(tab, key, ...);
end

function UIBase__newindex(tab, key, value)
	if UI['set__'..key] then
		UI['set__'..key](tab, value);
	end

	rawset(tab, key, value);
end

UI.metas = {};
UI.GetMeta = function(tabobj)
	if UI.metas[tabobj] then
		return  UI.metas[tabobj];
	end

	UI.metas[tabobj] = {__index = UIBase__index, __newindex = UIBase__newindex};
	for i, v in pairs(tabobj) do
		if type(v) == 'function' then
			UI.metas[tabobj][i] = v;
		end
	end

	return UI.metas[tabobj];
end

-- function UIBase__call(tab, key, value)
-- 	if ui['set__'..key] then
-- 		ui['set__'..key](tab, value);
-- 	end
-- end

local SelectedUI = {}
UISystem.mouseDown = function( b, x, y )
	for i, v in ipairs(UISystem.buttons) do
		if v.triggerMouseDown and v:triggerMouseDown( b, x, y ) then
			SelectedUI[#SelectedUI + 1] = v
		end
	end

	for i, v in ipairs(UISystem.uiviews) do
		if v.triggerMouseDown and v:triggerMouseDown( b, x, y ) then
			SelectedUI[#SelectedU + 1] = v
		end
	end

	return false;
end

UISystem.mousereleased = function( b, x, y )
	for i = 1, #SelectedUI do
		local selectui = SelectedUI[i]
		if selectui.triggerMouseRelease then
			selectui:triggerMouseRelease(b, x, y)
		end
	end

	SelectedUI = {}

	return false;
end

local MouseMovedSelectedUI
UISystem.mousemoved = function(x, y )
	if MouseMovedSelectedUI then
		if MouseMovedSelectedUI:triggerMouseMoved(x, y ) == false then
			MouseMovedSelectedUI = nil
		end
	end

	if not MouseMovedSelectedUI then
		for i, v in ipairs(UISystem.buttons) do
			if v.triggerMouseMoved and v:triggerMouseMoved(x, y ) then
				MouseMovedSelectedUI = v
			end
		end
	end

	if not MouseMovedSelectedUI then
		for i, v in ipairs(UISystem.uiviews) do
			if v.triggerMouseMoved and v:triggerMouseMoved( x, y ) then
				MouseMovedSelectedUI = v
			end
		end
	end

	return false;
end

UISystem.keyDown = function( keyCode )
	local  fouseuis = UISystem.fouseuis;
	for i, v in ipairs(fouseuis) do
	
		if ( UISystem.isTextInput( fouseuis[i] ) ) then
		
			TextInput.doActionForKeyDown( keyCode, fouseuis[i] )
			return true;
		end
	end

	return false;
end


app.mousepressed(function(x, y, button, istouch)
	UISystem.mouseDown(button, x, y)
end)

app.mousereleased(function(x, y, button, istouch)
	UISystem.mousereleased(button, x, y)
end)

app.mousemoved(function(x, y)
	UISystem.mousemoved(x, y)
end)