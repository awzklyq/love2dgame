--config
dofile('script/config.lua')

_G.TEST = false

--file
_G.log = require "script/log"
dofile('script/class.lua')
dofile("script/ui/uihelper.lua")
dofile('script/debug.lua')

_G.lovector = require "lovector"
dofile 'script/render/cameramanager.lua'

dofile 'script/light/lightmanager.lua'
dofile('script/application.lua')
dofile('script/render/render.lua')
dofile('script/render/canvas.lua')
dofile('script/render/image.lua')

dofile('script/common/color.lua')
dofile('script/common/filepath.lua')
dofile('script/file/file.lua')

dofile('script/xml/xmlload.lua')

dofile('script/map/terrain/tiled.lua')

dofile('script/polygon/rect.lua')
dofile('script/polygon/circle.lua')
dofile('script/polygon/line.lua')
dofile('script/polygon/box.lua')
dofile('script/polygon/mesh.lua')
dofile('script/3d/mesh/mesh3d.lua')
dofile('script/polygon/polygon.lua')

dofile('script/uisystem/uisystem.lua')
dofile('script/uisystem/button.lua')

dofile('script/math/math.lua')
dofile('script/math/vector.lua')
dofile('script/math/matrix.lua')
dofile('script/3d/math/vector3.lua')
dofile('script/3d/math/matrix3d.lua')

dofile('script/groupmanager.lua')

dofile('script/physics/world.lua')

dofile('script/entity/entity.lua')
dofile('script/entity/body.lua')
dofile('script/entity/me.lua')
dofile('script/entity/powerbar.lua')

dofile('script/grid/grid.lua')
dofile('script/shader/shader.lua')
dofile 'script/3d/camera/camera3d.lua'
dofile 'script/render/shadow.lua'

dofile 'script/3d/light/light.lua'

dofile 'script/3d/render/renderset.lua'

dofile 'script/3d/scene/scene.lua'
dofile 'script/3d/scene/scenenode.lua'

dofile 'script/3d/math/box.lua'

_G.mlib = require 'script/mlib' 

--游戏全局函数
local me = nil;
_G.setMe = function(obj)
	me = obj;
end

_G.getMe = function(obj)
	return me
end

if _G.TEST then
app.load(function()
	_G.GroupManager.loadGroup("Login");
end)

else
	dofile('script/test/ssao.lua')
end
