--file
_G.log = require "script/log"
dofile('script/class.lua')
dofile("script/ui/uihelper.lua")
dofile('script/debug.lua')

dofile 'script/render/cameramanager.lua'
dofile 'script/light/lightmanager.lua'
dofile('script/application.lua')
dofile('script/render/render.lua')

_G.lovector = require "lovector"
dofile('script/common/color.lua')

dofile('script/file/file.lua')

dofile('script/xml/xmlload.lua')

dofile('script/map/terrain/tiled.lua')

dofile('script/polygon/rect.lua')
dofile('script/polygon/circle.lua')
dofile('script/polygon/line.lua')

dofile('script/polygon/polygon.lua')

dofile('script/uisystem/uisystem.lua')
dofile('script/uisystem/button.lua')

dofile('script/math/math.lua')
dofile('script/math/vector.lua')
dofile('script/math/matrix.lua')

dofile('script/groupmanager.lua')

dofile('script/physics/world.lua')

dofile('script/entity/entity.lua')
dofile('script/entity/body.lua')
dofile('script/entity/me.lua')
_G.lovedebug.renderbox2d = true;   
_G.lovedebug.renderobject = true;

_G.lovedebug.showstat = false

app.load(function()
	_G.GroupManager.loadGroup("Login");
end)

--游戏全局函数
local me = nil;
_G.setMe = function(obj)
	me = obj;
end

_G.getMe = function(obj)
	return me
end