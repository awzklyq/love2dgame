function TextInput( x, y, w, h, text )
{
	UISystem.removeUI( this );
	this._x = x || 0;
	this.textx = this._x;
	this._y = y || 0;
	this._w = w || 0;
	this._h = h || 0;
	this.text = text || "";

	this.isEditor = true;
	this.borderWidth = 2;

	this.textColor = "rgba(0, 0, 0, 255)";
	this.setTextColor = function( color )
	{
		var temp = Math.DecompressionRGBA( color );
		this.textColor = "rgba(" + temp.r + "," + temp.g + "," + temp.b + "," + temp.a + ")";
	}
	
	this.borderColor = "rgba(0, 0, 0, 255)";
	this.setBorderColor = function( color )
	{
		var temp = Math.DecompressionRGBA( color );
		this.borderColor = "rgba(" + temp.r + "," + temp.g + "," + temp.b + "," + temp.a + ")";
	}

	this.bgColor = "rgba(255, 255, 255, 255)";
	this.setBackgroundColor = function( color )
	{
		var temp = Math.DecompressionRGBA( color );
		this.bgColor = "rgba(" + temp.r + "," + temp.g + "," + temp.b + "," + temp.a + ")";
	}

	this.cursorColor = "rgba(0, 0, 0, 255)";
	this.cursorWidth = 1;
	this.setCursorColor = function( color )
	{
		var temp = Math.DecompressionRGBA( color );
		this.cursorColor = "rgba(" + temp.r + "," + temp.g + "," + temp.b + "," + temp.a + ")";
	}

	this.tick = 0;
	this.showCursorInterval = 500;
	this.showCursor = true;
	this.fouse = false;
	this.cursorX = this.textx + StringEx.getStringPixelSize( this.text );
	this.curindex = this.text.length - 1;
	this.draw = function( )
	{
		if ( this.checkSWFFrame ( ) == false )
			return;

		var context = window.context;
		context.save( );
		context.beginPath( );
		context.rect( this._x, this._y, this._w, this._h );
		context.clip( );
		context.lineWidth = this.borderWidth;
		context.strokeStyle = this.borderColor;
		
		context.strokeRect( this._x, this._y, this._w, this._h );

		context.fillStyle = this.bgColor;
		context.fillRect( this._x + 100, this._y, this._w, this._h );

		context.fillStyle =  this.textColor;
		context.fillText( this.text, this.textx, this._y + this._h - this.borderWidth );

		this.tick += Global.elapse;

		if ( this.tick >= this.showCursorInterval )
		{
			this.showCursor = !this.showCursor;
			this.tick = 0;
		}
		
		if ( this.fouse && this.showCursor )
		{
			context.lineWidth = this.cursorWidth;
			context.fillStyle = this.textColor;
			context.moveTo( this.cursorX, this._y );
			context.lineTo( this.cursorX, this._y + this._h );
		}

		context.stroke( );

		context.closePath( );
		context.restore( );
	}

	this.insert = function( x, y )
	{
		return ( x > this._x ) && ( x < this._x + this._w + this.borderWidth ) && ( y > this._y - this.borderWidth ) && ( y < this._y + this._h + this.borderWidth );
	}

	this.setCursorPostion = function( x, y )
	{
		var xx = x - this._x;
		var textwidth = StringEx.getStringPixelSize( this.text );
		if ( xx > textwidth )
		{
			this.curindex = this.text.length - 1;
			this.cursorX = this._x + textwidth;
		}
		else
		{
			this.curindex = TextInput.setCursorPostionEx( xx, 0, this.text.length, this.text );
			this.cursorX = this.textx + StringEx.getStringPixelSize( StringEx.getSubString( this.text, 0, this.curindex ) );
		}
	}

	this.resetCursorPostion = function( )
	{
		this.cursorX = this.textx + StringEx.getStringPixelSize( StringEx.getSubString( this.text, 0, this.curindex ) );
	}

	// Called from parent.
	this.triggerResizeXY = function( intervalx, intervaly )
	{
		this.textx += intervalx;
	}

	this.triggerMouseDown = function( b, x, y )
	{
		if ( this.isEditor == false )
			return;

		this.fouse = false;
		if ( this.insert( x, y ) == false )
			return false;
	
		this.fouse = true;
		this.setCursorPostion( x, y );
		UISystem.fouseuis.push( this );
		return true;
	}

	this.release = function( )
	{
		for ( var i = 0; i < UISystem.textinput.length; i ++ )
		{
			if ( UISystem.textinput[i] == this )
			{
				UISystem.textinput.splice( i, 1 );
				break;
			}
		}
	}

	UISystem.textinputs.push( this );

	this.type = "TextInput";

	UISystem.addUI( this );
}

TextInput.setCursorPostionEx = function( dis, start, end, text )
{
	var temp = Math.floor( 0.5 * ( start + end ) );
	if ( temp == start || temp + 1 == end )
		return temp;

	var size1 = StringEx.getStringPixelSize( StringEx.getSubString( text, 0, temp ) );
	var size2 = StringEx.getStringPixelSize( StringEx.getSubString( text, 0, temp + 1 ) );
	if ( size1 <= dis && size2 >= dis )
		return temp;
	else if ( size1 > dis )
		return TextInput.setCursorPostionEx( dis, start, temp, text );

	// if ( size2 < dis ).
	return TextInput.setCursorPostionEx( dis, temp + 1, end, text );
}

TextInput.prototype = Global.UI;

// Windows...
TextInput.doActionForKeyDown = function( keyCode, textinput)
{
	if ( textinput.isEditor == false )
		return;

	if ( System.KeyBack == keyCode && textinput.curindex != 0 )
	{
		textinput.text = StringEx.getRemoveAtResult( textinput.text, textinput.curindex );
		textinput.curindex --;
		textinput.curindex = Math.max( 0, textinput.curindex );
		textinput.resetCursorPostion( );
	}
	else if ( System.KeyDel == keyCode && textinput.curindex < textinput.text.length )
	{
		textinput.text = StringEx.getRemoveAtResult( textinput.text, textinput.curindex + 1 );
		textinput.resetCursorPostion( );
	}
	else if ( System.KeyLeft == keyCode && textinput.curindex != 0 )
	{
		textinput.curindex --;
		textinput.curindex = Math.max( 0, textinput.curindex );
		textinput.resetCursorPostion( );
	}
	else if ( System.KeyRight == keyCode && textinput.curindex < textinput.text.length )
	{
		textinput.curindex ++;
		textinput.resetCursorPostion( );
	}
	else if ( keyCode >= System.KeyA && keyCode <= System.KeyZ )
	{
		textinput.text = StringEx.getInsertResult( textinput.text, textinput.curindex, StringEx.getUnicode( keyCode ) );
		textinput.curindex ++;
		textinput.resetCursorPostion( );
	}

	if ( textinput.cursorX > textinput.x + textinput.w )
	{
		textinput.cursorX = textinput.x + textinput.w - 4;
		textinput.textx = textinput.cursorX - StringEx.getStringPixelSize( textinput.text );
	}
	else if ( textinput.cursorX < textinput.x + textinput.borderWidth )
	{
		var temp = textinput.x + textinput.borderWidth;
		if ( textinput.textx < temp )
			textinput.textx += temp - textinput.cursorX + 4;

		textinput.cursorX = temp;
	}
}