_G.UI = {}

UI.State_Normal = 1;
UI.State_Press = 2;
UI.State_Hover = 3;

UI.UISystem = {};

dofile('script/uisystem/button.lua')
dofile('script/uisystem/text.lua')
dofile('script/uisystem/scrollbar.lua')
dofile('script/uisystem/checkbox.lua')
dofile('script/uisystem/ColorPlane.lua')
dofile('script/uisystem/ComboBox.lua')
dofile('script/uisystem/CurveDataPlane.lua')

local UISystem = UI.UISystem;
UISystem.buttons = {};

UISystem.texts = {};

UISystem.scrollbars = {};

UISystem.checkboxs = {};
UISystem.ComboBoxs = {};

UISystem.CurveDataPlanes = {};

UISystem.uiviews = {}

UISystem.RemoveUIFormTarry = function(Elements, ui)
	for i = 1, #Elements do
		if Elements[i] == ui then
			table.remove(Elements, i)
			return true
		end
	end

	return false
end

UISystem.removeUI = function( ui )
	if ( UISystem.IsButton( ui )	) then
		UISystem.RemoveUIFormTarry(UISystem.buttons, ui)
	elseif ( UISystem.IsText( ui ) ) then
		UISystem.RemoveUIFormTarry(UISystem.texts, ui)
	elseif UISystem.IsScrollBar(ui) then
		UISystem.RemoveUIFormTarry(UISystem.scrollbars, ui)
	elseif UISystem.IsCheckBox(ui) then
		UISystem.RemoveUIFormTarry(UISystem.checkboxs, ui)
	elseif UISystem.IsComboBox(ui) then
		UISystem.RemoveUIFormTarry(UISystem.ComboBoxs, ui)
	elseif UISystem.IsCurveDataPlane(ui) then
		UISystem.RemoveUIFormTarry(UISystem.CurveDataPlanes, ui)
	else
		UISystem.RemoveUIFormTarry(UISystem.uiviews, ui)
	end
end

UISystem.addUI = function( ui )
	UISystem.RemoveUIFormTarry(ui)
	if ( UISystem.IsButton( ui )) then
		table.insert( UISystem.buttons, ui);
	elseif ( UISystem.IsText( ui ) ) then
		table.insert( UISystem.texts, ui);
	elseif UISystem.IsScrollBar(ui) then
		table.insert( UISystem.scrollbars, ui);
	elseif UISystem.IsCheckBox(ui) then
		table.insert( UISystem.checkboxs, ui)
	elseif UISystem.IsComboBox(ui) then
		table.insert(UISystem.ComboBoxs, ui)
	elseif UISystem.IsCurveDataPlane(ui) then
		table.insert(UISystem.CurveDataPlanes, ui)
	else
		table.insert( UISystem.uiviews, ui)
	end
end

UISystem.render = function( e )
	for i, v in ipairs(UISystem.buttons) do
		v:draw();
	end

	for i, v in ipairs(UISystem.texts) do
		v:draw();
	end

	for i, v in ipairs(UISystem.scrollbars) do
		v:draw();
	end

	for i, v in ipairs(UISystem.checkboxs) do
		v:draw();
	end

	for i, v in ipairs(UISystem.uiviews) do
		v:draw();
	end

	for i, v in ipairs(UISystem.ComboBoxs) do
		v:draw();
	end

	for i, v in ipairs(UISystem.CurveDataPlanes) do
		v:draw();
	end
end

_G.app.afterrender(function(e)
    UISystem.render(e) 
end)

UISystem.IsButton = function( obj )
	return obj and obj.renderid and obj.renderid == Render.UIButtonId;
end

UISystem.IsText = function( obj )
	return obj and obj.renderid and obj.renderid == Render.UITextId;
end

UISystem.IsScrollBar = function( obj )
	return obj and obj.renderid and obj.renderid == Render.UIScrollBarId;
end

UISystem.IsCheckBox = function( obj )
	return obj and obj.renderid and obj.renderid == Render.UICheckBoxId;
end

UISystem.IsComboBox = function( obj )
	return obj and obj.renderid and obj.renderid == Render.UIComboBoxId;
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

UISystem.IsCurveDataPlane = function( obj )
	return obj and obj.renderid and obj.renderid == Render.CurveDataPlaneId;
end

UISystem.isUIView = function( obj, isview )

	if ( isview == true ) then
		if ( obj.type == "UIView" ) then
			return;
		end
	end

	return ( obj.type == "UIView" ) or UISystem.IsButton( obj ) or UISystem.IsText( obj ) or UISystem.isTextArea( obj ) or UISystem.isTextInput( obj ) or  UISystem.IsComboBox( obj ) or  UISystem.IsCurveDataPlane( obj );
end

UI.get__x = function( self )
	return self._x;
end

UI.set__x = function( self, xx )
	if type(xx) ~= 'number' then
		return
	end

	self._x = xx;

	if self.ResetXYWH then
		self:ResetXYWH()
	end
end


UI.get__y = function(self)
	return self._y;
end

UI.set__y = function(self, yy)
	if type(yy) ~= 'number' then
		return
	end

	self._y = yy

	if self.ResetXYWH then
		self:ResetXYWH()
	end
end

UI.get__w = function(self)
	return self._w;
end

UI.set__w = function(self, ww)
	self._w = ww;

	if self.ResetXYWH then
		self:ResetXYWH()
	end
end

UI.get__h = function(self )
	return self._h;
end
UI.set__h = function( self, hh )
	self._h = hh;

	if self.ResetXYWH then
		self:ResetXYWH()
	end
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
	local TypeObject = rawget(tab, "TypeObject");
	if TypeObject then
		if TypeObject['get__'..key] then
			return TypeObject['get__'..key](tab);
		end
	end

	if UI['get__'..key] then
		return UI['get__'..key](tab);
	end
	
	if TypeObject and TypeObject[key] then
		return TypeObject[key];
	end

	return rawget(tab, key, ...);
end

function UIBase__newindex(tab, key, value)

	local TypeObject = rawget(tab, "TypeObject");
	if TypeObject then
		if TypeObject['set__'..key] then
			return TypeObject['set__'..key](tab, value);
		end
	end

	if UI['set__'..key] then
		return UI['set__'..key](tab, value);
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

UI.CreateMetatable = function(Obj)
	local newobj = setmetatable({}, UI.GetMeta(Obj))

	newobj.TypeObject = Obj

	return newobj
end

-- function UIBase__call(tab, key, value)
-- 	if ui['set__'..key] then
-- 		ui['set__'..key](tab, value);
-- 	end
-- end

local SelectedUI = {}
UISystem.mouseDown = function( b, x, y )
	
	for i, v in ipairs(UISystem.ComboBoxs) do
		if v.triggerMouseDown and v:triggerMouseDown( b, x, y ) then
			SelectedUI[#SelectedUI + 1] = v
		end
	end
	
	for i, v in ipairs(UISystem.buttons) do
		if v.triggerMouseDown and v:triggerMouseDown( b, x, y ) then
			SelectedUI[#SelectedUI + 1] = v
		end
	end

	for i, v in ipairs(UISystem.scrollbars) do
		if v.triggerMouseDown and v:triggerMouseDown( b, x, y ) then
			SelectedUI[#SelectedUI + 1] = v
		end
	end

	for i, v in ipairs(UISystem.CurveDataPlanes) do
		if v.triggerMouseDown and v:triggerMouseDown( b, x, y ) then
			SelectedUI[#SelectedUI + 1] = v
		end
	end

	for i, v in ipairs(UISystem.checkboxs) do
		if v.triggerMouseDown then
			v:triggerMouseDown( b, x, y )
		end
	end

	for i, v in ipairs(UISystem.uiviews) do
		if v.triggerMouseDown and v:triggerMouseDown( b, x, y ) then
			SelectedUI[#SelectedUI + 1] = v
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

UI.HasFoucsUI = function()
	return #SelectedUI > 0
end

UI.IsSelectUI = function(ui)
	for i = 1, #SelectedUI do
		if ui == SelectedUI[i] then
			return true
		end
	end

	return false
end

local MouseMovedSelectedUI = nil
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
				break
			end
		end
	end

	if not MouseMovedSelectedUI then
		for i, v in ipairs(UISystem.scrollbars) do
			if v.triggerMouseMoved and v:triggerMouseMoved(x, y ) then
				MouseMovedSelectedUI = v
				break
			end
		end
	end

	if not MouseMovedSelectedUI then
		for i, v in ipairs(UISystem.CurveDataPlanes) do
			if v.triggerMouseMoved and v:triggerMouseMoved( x, y ) then
				MouseMovedSelectedUI = v
				break
			end
		end
	end

	if not MouseMovedSelectedUI then
		for i, v in ipairs(UISystem.checkboxs) do
			if v.triggerMouseMoved and v:triggerMouseMoved( x, y ) then
				MouseMovedSelectedUI = v
				break
			end
		end
	end

	if not MouseMovedSelectedUI then
		for i, v in ipairs(UISystem.uiviews) do
			if v.triggerMouseMoved and v:triggerMouseMoved( x, y ) then
				MouseMovedSelectedUI = v
				break
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