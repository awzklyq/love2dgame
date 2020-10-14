function UIView( x, y, w, h, name, backimage )
{
	
	this._x = x || 0;
	this._y = y || 0;
	this._w = w || 0;
	this._h = h || 0;

	this.useMatrix = false;

	this.mat = new Matrix( );

	// For swf.
	this._depth = 0;
	this._order = 0;

	this._name = name || "";
	this.image = backimage;

	this.color = '';

	this.setImage = function( img )
	{
		if ( this.image )
			delete this.image;

		this.image = img;
	}

	this.elements = new ArrayEx( );
	// this.elements.type = ArrayEx.ReversSort;
	this.addUI = function( ui, order, frame )
	{
		if ( UISystem.isUIView( ui ) )
		{
			ui._parent = this;
			if ( order )
			{
				this.elements.insertSorting( ui, 0, this.elements.length, "_order" );
			}
			else
			{
				this.elements.push( ui );
			}

			UISystem.removeUI( ui );
			
			if ( this.useMatrix != true )
			{
				ui._x += this._x;
				ui._y += this._y;
			}
		}

		if ( ui._name != null && ui._name != "" )
			this[ui._name] = ui;
	}

	this.updateFrames = function( )
	{
		// for ( var i = 0; i < this.elements.length; i ++ )
			// log(this.elements[i].name);

		// for ( var i = 0; i < this.elements.length; i ++ )
			// this.elements[i].updateFrames( );
	}

	this.removeUI = function( ui )
	{
		if ( UISystem.isUIView( ui ) == false || ui._parent != this )
			return

		this.elements.remove( ui );

		if ( this[ui._name] != null )
			delete this[ui._name];

		delete ui._parent;
		ui._parent = null;
	}

	this.clearUIs = function( )
	{
		for ( var i = 0; i < this.elements.length; i ++ )
			delete this.elements._parent;

		this.elements.clear( );
	}

	this.checkSWFFrame = function( )
	{
		if ( this.swf == null || this.swf == false )
			return true;

		return this.tick >= this.startFrame && this.tick <= this.endFrame;
	}

	this.update = function( e )
	{
		if ( this.swf == null || this.swf == false )
			return;

		if ( this.needUpdate == false )
			return;

		if ( this._loop == false )
		{
			if ( this.tick < this.duration )
			{
				this.tick += this.interval || 1;
				if ( this.tick > this.duration )
					this.tick = this.duration;
			}
		}
		else
		{
			this.tick += this.interval || 1;
			if ( this.tick > this.duration )
				this.tick = 0;
		}

		for ( var i = 0; i < this.elements.length; i ++ )
			this.elements[i].update( e );
	}

	this.draw = function( e )
	{
		if ( this.checkSWFFrame( ) == false )
			return;

		if ( this.useMatrix )
			Global.pushMatrix( this.mat );
		
		if ( this.image != null )
		{
			this.image.drawImage( this.useMatrix ? 0 : this._x, this.useMatrix ? 0 : this._y, this._w, this._h );	
		}

		var elements = this.elements;
		for ( var i = 0; i < elements.length; i ++ )
			elements[i].draw( e );

		if ( this.useMatrix )
			Global.popMatrix( );
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

	this.sortDepth = function( )
	{
		if ( this.elements.length < 2 )
			return;
	
	}

	this.reverse = function( )
	{
		this.elements.reverse( );
		for ( var i = 0; i < this.elements.length; i ++ )
			this.elements[i].reverse( );
	}

	this.gotoAndPlay = function( current )
	{
		if ( this.swf == null || this.swf == false )
			return;

		this.tick = current > this.duration ? this.duration : current;
		this.needUpdate = true;

		for ( var i = 0; i < this.elements.length; i ++ )
			this.elements[i].gotoAndPlay( current );
	}
	
	this.gotoAndStop = function( current )
	{
		if ( this.swf == null || this.swf == false )
			return;

		this.tick = current > this.duration ? this.duration : current;

		for ( var i = 0; i < this.elements.length; i ++ )
			this.elements[i].gotoAndStop( current );
	}
	
	this.logInfo = function( )
	{
		log( this.type, this._depth, this.typename );
		for ( var i = 0; i < this.elements.length; i ++ )
			this.elements[i].logInfo( );

		log( );
	}

	UISystem.addUI( this );
	this.type = "UIView";
}

UIView.prototype = Global.UI;