UI.UIList = {}
function UI.UIList.new( x, y, w, h )
{
	UI.UISystem.removeUI( this );
	this._x = x || 0;
	this._y = y || 0;
	this._w = w || 0;
	this._h = h || 0;

	this.draw = function( )
	{
		if ( this.checkSWFFrame ( ) == false )
			return;

		var elements = this.elements;
		for ( var i = 0; i < elements.length; i ++ )
			elements[i].draw( );
	}
	
	this.triggerMouseDown = function( b, x, y )
	{
		var elements = this.elements;
		for ( var i = 0; i < elements.length; i ++ )
		{
			if ( Global.isFunction( elements[i].triggerMouseDown ) && elements[i].triggerMouseDown( b, x, y ) )
				return true;
		}

		return false;
	}

	this.type = "UIList";
	UISystem.addUI( this );
}

UIList.prototype = new UIView( );