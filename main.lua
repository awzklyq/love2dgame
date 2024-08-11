--https://www.imooc.com/wenda/detail/524261
_G.luabit = require"bit"

--config
dofile('script/config.lua')

_G.TEST = false

--file
_G.log = require "script/log"
dofile('script/class.lua')
dofile('script/debug.lua')
dofile('script/GlobalFunction.lua')

_G.lovector = require "lovector"
dofile 'script/render/cameramanager.lua'

dofile 'script/light/lightmanager.lua'
dofile('script/application.lua')
dofile('script/render/render.lua')
dofile('script/render/canvas.lua')
dofile('script/render/image.lua')

dofile('script/common/color.lua')
dofile('script/common/audio.lua')
dofile('script/common/filepath.lua')
dofile('script/common/earclip.lua')
dofile('script/common/voronoi.lua')
dofile('script/common/pbr.lua')
dofile('script/common/radarfrustum.lua')
dofile('script/common/SpaceSplit.lua')
dofile('script/common/psnr.lua')
dofile('script/common/optional.lua')
dofile('script/common/MehGenusGenerate.lua')

dofile('script/file/file.lua')

dofile('script/xml/xmlload.lua')

dofile('script/map/terrain/tiled.lua')

dofile('script/shader/shader.lua')
dofile('script/shader/shaderfunction.lua')
dofile('script/shader/shader_octahedralmap.lua')

dofile('script/polygon/polygonevent.lua')
dofile('script/polygon/rect.lua')
dofile('script/polygon/circle.lua')
dofile('script/polygon/line.lua')
dofile('script/polygon/ray.lua')
dofile('script/polygon/HermiteCurve.lua')
dofile('script/polygon/BezierCurve.lua')
dofile('script/polygon/edge.lua')
dofile('script/polygon/box.lua')
dofile('script/polygon/mesh.lua')
dofile('script/3d/mesh/mesh3d.lua')
dofile('script/3d/mesh/aixs.lua')
dofile('script/3d/mesh/aixs.lua')

dofile('script/polygon/triangle.lua')
dofile('script/polygon/triangle3d.lua')
dofile('script/polygon/MeshVolum.lua')
dofile('script/polygon/MortonCluster.lua')

dofile('script/3d/terrain/tile.lua')
dofile 'script/3d/terrain/tileshader.lua'

dofile('script/polygon/polygon.lua')

dofile('script/uisystem/uisystem.lua')

dofile('script/math/math.lua')
dofile('script/math/MathFunctionDisplay.lua')
dofile('script/math/vector.lua')
dofile('script/math/point2d.lua')
dofile('script/math/complex.lua')
dofile('script/math/matrix.lua')
dofile('script/math/matrix2d.lua')
dofile('script/math/matrixs.lua')
dofile('script/math/RotationMatrix.lua')
dofile 'script/math/kmeans.lua'
dofile('script/3d/math/vector3.lua')
dofile('script/3d/math/vector4.lua')
dofile('script/3d/math/matrix3d.lua')
dofile('script/3d/math/harmonics.lua')

dofile('script/polygon/collision2d.lua')

dofile('script/groupmanager.lua')

dofile('script/physics/world.lua')

dofile('script/entity/entity.lua')
dofile('script/entity/bullet.lua')
dofile('script/entity/body.lua')
dofile('script/entity/me.lua')
dofile('script/entity/powerbar.lua')

dofile('script/grid/grid.lua')
dofile 'script/3d/camera/camera3d.lua'
dofile 'script/render/shadow.lua'

dofile 'script/3d/light/light.lua'

dofile 'script/render/hdrsetting.lua'

dofile 'script/3d/render/renderset.lua'

dofile 'script/3d/scene/scene.lua'
dofile 'script/3d/scene/scenenode.lua'
dofile 'script/3d/scene/octree.lua'
dofile 'script/3d/scene/quadtree.lua'

dofile 'script/3d/math/plane.lua'
dofile 'script/3d/math/frustum.lua'
dofile 'script/3d/math/box.lua'
dofile 'script/3d/math/ray.lua'
dofile 'script/3d/math/perlinnoise1.lua'
dofile 'script/3d/math/perlinnoise2.lua'
dofile 'script/3d/math/fbm.lua'

dofile 'script/3d/water/MeshWater.lua'
dofile 'script/3d/water/watershader.lua'

dofile 'script/text/lovescreentext.lua'

dofile 'script/render/font.lua'

dofile 'script/common/timer.lua'

dofile 'script/common/RamerDouglasPeucker.lua'

dofile 'script/postprocess/tonemapping.lua'
dofile 'script/postprocess/bloom.lua'
dofile 'script/postprocess/bloom2.lua'
dofile 'script/postprocess/bloom3.lua'
dofile 'script/postprocess/outline.lua'
dofile 'script/postprocess/ssao.lua'
dofile 'script/postprocess/ssdo.lua'
dofile 'script/postprocess/hbao.lua'
dofile 'script/postprocess/gtao.lua'
dofile 'script/postprocess/taa.lua'
dofile 'script/postprocess/gaussianfilter.lua'
dofile 'script/postprocess/simplessgi.lua'
dofile 'script/postprocess/esmblur.lua'
dofile 'script/postprocess/VelocityBuff.lua'
dofile 'script/postprocess/depthoffield.lua'
dofile 'script/postprocess/godray.lua'
dofile 'script/postprocess/watercolorfilter.lua'
dofile 'script/postprocess/fog.lua'
dofile 'script/postprocess/lightnode.lua'
dofile 'script/3d/effect/motionvector.lua'

dofile 'script/3d/math/edge3d.lua'
dofile 'script/3d/math/face.lua'
dofile 'script/3d/math/point.lua'

dofile('script/3d/mesh/qem.lua')

dofile('script/shader/ImageAnimaShader.lua')

dofile('script/render/imageanima.lua')

dofile('script/raytrace/CPURaytraceUseDDA.lua')
dofile 'script/ballgame/collision/collisionmanager.lua'
dofile 'script/ballgame/collision/collisionbinder.lua'
dofile 'script/ballgame/collision/collisiongroup.lua'
dofile 'script/ballgame/collision/collisionphysics.lua'

FileManager.addAllPath("assert")

_G.mlib = require 'script/mlib' 

--游戏全局函数
local me = nil;
_G.setMe = function(obj)
	me = obj;
end

_G.getMe = function(obj)
	return me
end

_G.TEST = true
if not _G.TEST then

	app.load(function()
		_G.GroupManager.loadGroup("Login");
	end)

else
	dofile('script/test/test_meshgenus.lua')--test_MeshVolume  test_BezierCurve.lua
	-- dofile('script/demo/ball/demo_ball.lua') test_SpaceSplit.lua
end
--dofile()

 