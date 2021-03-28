_G.ShaderFunction = {}

_G.ShaderFunction.getShadowPCFCode = [[
    float getShadowPCF(vec2 suv, sampler2D shadowmap, float depth, float shadowmapsize)
    {
        float suvx = suv.x * shadowmapsize;
        float suvy = suv.y * shadowmapsize;

        vec2 Fraction = fract(suv * shadowmapsize);

        float offset = 1 / shadowmapsize;
        suv = vec2((suvx - Fraction.x + 0.5)/ shadowmapsize, (suvy - Fraction.y + 0.5) / shadowmapsize); // bias to get reliable texel center content

        
        float shadow = texture2D(shadowmap, suv).r > depth ? 1 : 0;

        float shadow1 = texture2D(shadowmap, suv + vec2(offset, 0)).r > depth ? 1 : 0;
        float shadow2 = texture2D(shadowmap, suv + vec2(-offset, 0)).r > depth ? 1 : 0;

        float shadow3 = texture2D(shadowmap, suv + vec2(0, offset)).r > depth ? 1 : 0;
        float shadow4 = texture2D(shadowmap, suv + vec2(0, -offset)).r > depth ? 1 : 0;

        float shadow5 = texture2D(shadowmap, suv + vec2(offset, offset)).r > depth ? 1 : 0;
        float shadow6 = texture2D(shadowmap, suv + vec2(-offset, -offset)).r > depth ? 1 : 0;

        float shadow7 = texture2D(shadowmap, suv + vec2(-offset, offset)).r > depth ? 1 : 0;
        float shadow8 = texture2D(shadowmap, suv + vec2(offset, -offset)).r > depth ? 1 : 0;

        vec3 Results;

        Results.x = shadow8 * (1.0f - Fraction.x);
        Results.y = shadow1 * (1.0f - Fraction.x);
        Results.z = shadow5 * (1.0f - Fraction.x);
        Results.x += shadow4;
        Results.y += shadow;
        Results.z += shadow3;
        Results.x += shadow6 * Fraction.x;
        Results.y += shadow2 * Fraction.x;
        Results.z += shadow7 * Fraction.x;
    
        return clamp(0.25f * dot(Results, vec3(1.0 - Fraction.y, 1.0, Fraction.y)), 0, 1);
    }
]]
_G.ShaderFunction.ShadowPCFFunctionName = "getShadowPCF"
