_G.OutLine = {}
OutLine.Canvae = Canvas.new(1, 1, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
OutLine.Canvae.renderWidth = 1
OutLine.Canvae.renderHeight = 1
OutLine.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

OutLine.LineWidth = 4;
OutLine.Color = LColor.new(255,0,0,255);
OutLine.Threshold = 1
OutLine.Execute = function(Canva1)
   
    if OutLine.Canvae.renderWidth ~= Canva1.renderWidth  or OutLine.Canvae.renderHeight ~= Canva1.renderHeight then
        OutLine.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight , {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
        OutLine.Canvae.renderWidth = Canva1.renderWidth
        OutLine.Canvae.renderHeight = Canva1.renderHeight

        OutLine.meshquad = _G.MeshQuad.new(OutLine.Canvae.renderWidth, OutLine.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(OutLine.Canvae.obj)
    love.graphics.clear()
    OutLine.meshquad:setCanvas(Canva1)
    OutLine.meshquad.shader = Shader.GetOutLineShader(OutLine.LineWidth/ OutLine.Canvae.renderWidth, OutLine.Color, OutLine.Threshold)
    OutLine.meshquad:draw()
    love.graphics.setCanvas()
    return OutLine.Canvae
end


function Shader.GetOutLineShader(lw, color, threshold)

    if Shader['shader_GetOutLineShader']  then
        Shader['shader_GetOutLineShader']:send("lw", lw)
        Shader['shader_GetOutLineShader']:send("threshold", threshold)
        Shader['shader_GetOutLineShader']:send("edgecolor", {color._r, color._g, color._b, color._a})
        return Shader['shader_GetOutLineShader']
    end
    local pixelcode = 'uniform float l;\n'
    pixelcode = pixelcode .. _G.ShaderFunction.Luminance
    pixelcode = pixelcode .. [[
    varying vec2 vTexCoord2;
    uniform float lw;
    uniform float threshold;
    uniform vec4 edgecolor;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec2 offsets[9];

		offsets[0] = vec2(-1, 1);
		offsets[1] = vec2(0, 1);
		offsets[2] = vec2(1, 1);
		offsets[3] = vec2(-1, 0);
		offsets[4] = vec2(0, 0);
		offsets[5] = vec2(1, 0);
		offsets[6] = vec2(-1, -1);
		offsets[7] = vec2(0, -1);
		offsets[8] = vec2(1, -1);

		mat3 sobelHorizontal = mat3(
			-1, 0, 1,
			-2, 0, 2,
			-1, 0, 1
			);
        mat3 sobelVertical = mat3(
			-1, -2, -1,
			0, 0, 0,
			1, 2, 1
			);
        vec4 sobelH = vec4(0, 0, 0, 0);
		vec4 sobelV = vec4(0, 0, 0, 0);
		vec2 adjacentPixel = vec2(lw, lw);//_MainTex_TexelSize.xy * _SampleDistance;
		for (int m = 0; m < 3; m++)
			for (int n = 0; n < 3; n++)
			{
				sobelH += texture2D(tex, vTexCoord2 + offsets[m * 3 + n] * adjacentPixel) * sobelHorizontal[m][n];
				sobelV += texture2D(tex, vTexCoord2 + offsets[m * 3 + n] * adjacentPixel) * sobelVertical[m][n];
			}

		float sobel = length(sobelH * sobelH + sobelV * sobelV);

        vec4 sceneColor = texture2D(tex, vTexCoord2);
		// Get edge value based on sobel value and threshold
		float edgeMask = clamp(mix(0.0, sobel, threshold), 0, 1);
		vec3 EdgeMaskColor = vec3(edgeMask, edgeMask, edgeMask);
		//sceneColor = mix(sceneColor, _TestColor, _BgFade);

		vec3 finalColor = clamp((EdgeMaskColor * edgecolor.rgb) + (sceneColor.rgb - EdgeMaskColor), 0, 1);
		return vec4(finalColor, 1);

    }
]]

    local vertexcode = [[
    varying vec2 vTexCoord2;
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        vTexCoord2 =  VertexTexCoord.xy;
        return transform_projection * vertex_position;
    }
]]

    local shader =   Shader.new(pixelcode, vertexcode)
    shader:send("lw", lw)
    shader:send("threshold", threshold)
    shader:send("edgecolor", {color._r, color._g, color._b, color._a})
    Shader['shader_GetOutLineShader'] = shader
    return shader
end
