UI.Text = {}
function UI.Text.new( text, x, y, w, h )
	local text = setmetatable({},UI.GetMeta(UI.Text));
	UISystem.removeUI( text );
	text.type = "Text";
	text._x = x or 0;
	text._y = y or 0;
	text._w = w or 0;
	text._h = h or 0;
	text.text = text or "";

	text.lineWidth = 2;

	UISystem.addUI( text );
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

	return text;
end

function UI.Text:setColor( color1, color2 )
	
	-- local temp = Math.DecompressionRGBA( color1 );
	-- self.color1 = "rgba(" + temp.r + "," + temp.g + "," + temp.b + "," + temp.a + ")";
	-- temp = Math.DecompressionRGBA( color2 );
	-- self.color2 = "rgba(" + temp.r + "," + temp.g + "," + temp.b + "," + temp.a + ")";
end

function UI.Text:draw( )
	
end
