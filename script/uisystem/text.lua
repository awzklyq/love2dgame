UI.Text = {}
local UIText = UI.Text
local UISystem = UI.UISystem

function UIText.new( text, x, y, w, h )
	local uitext = setmetatable({}, UI.GetMeta(UIText));
	-- UISystem.removeUI( uitext );

	uitext.TypeObject = UIText;--must be
	uitext.type = "Text";
	uitext._x = x or 0;
	uitext._y = y or 0;
	uitext._w = w or 0;
	uitext._h = h or 0;
	uitext.text = text or "";

	uitext.lineWidth = 2;

	UISystem.addUI( uitext );
	-- text.font = Global.FONT;
	-- text.setFont = function( font )
	-- {
	-- 	text.font = font+"px Georgia";
	-- }

	-- text.style = Global.FILLSTYLE;
	-- self.setStyle = function( style )
	-- {
	-- 	self.style = style;
	-- }

	return uitext;
end

function UIText:setColor( color1, color2 )
	
	-- local temp = Math.DecompressionRGBA( color1 );
	-- self.color1 = "rgba(" + temp.r + "," + temp.g + "," + temp.b + "," + temp.a + ")";
	-- temp = Math.DecompressionRGBA( color2 );
	-- self.color2 = "rgba(" + temp.r + "," + temp.g + "," + temp.b + "," + temp.a + ")";
end

function UIText:setFont( )
	
end

function UIText:draw( )
	
end
