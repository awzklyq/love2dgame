_G.ShaderFunction.GetNoise = [[
vec2 hash( vec2 p ) // replace this by something better
{
    p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float Noise( in vec2 p )
{
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;

    vec2  i = floor( p + (p.x+p.y)*K1 );
    vec2  a = p - i + (i.x+i.y)*K2;
    float m = step(a.y,a.x); 
    vec2  o = vec2(m,1.0-m);
    vec2  b = a - o + K2;
    vec2  c = a - 1.0 + 2.0*K2;
    vec3  h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
    vec3  n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    return dot( n, vec3(70.0) );
}
]]

_G.ShaderFunction.GetTTF = [[

    float func_omega(float k, float g)
    {
        return sqrt(g*k);
    }

    vec2 twiddle(float kn, float km, vec2 twiddlev, vec2 twiddleconj, float t, float g)
    {
        float k = length(vec2(kn, km));
        vec2 term1 = twiddlev * exp(vec2(0.0, func_omega(k, g)*t));
        vec2 term2 = twiddleconj * exp(vec2(0.0, -func_omega(k, g)*t));
        return term1 + term2;
    }
]]

_G.ShaderFunction.Luminance = [[
    float Luminance(vec3 basecolor)
    {
        return 0.2126 * basecolor.x + 0.7152 * basecolor.y + 0.0722 * basecolor.z;
    }
]]

_G.ShaderFunction.CircleSampler = [[
    vec2 CircleSampler(float SliceCount, float Start, float Offset)
    {
        float radian = (3.141592 * 2.0 * (1.0 / SliceCount)) * (Start + Offset);
        return vec2(sin(radian), cos(radian));
    }
]]

_G.ShaderFunction.GetESMValue = [[
    float GetESMValue(vec2 suv, sampler2D shadowmap, float depth, float ESM_C)
    {
        vec2 shadowdepth = texture2D(shadowmap, suv).rg;
        float Shadow = clamp( exp( -ESM_C * ( shadowdepth.x - depth ) ), 0.0, 1.0 );
        return 1 - Shadow;
    }
]]

_G.ShaderFunction.ScreenAndViewPortFunc = [[
vec2 ViewportUVToScreenPos(vec2 ViewportUV)
{
    return vec2(2 * ViewportUV.x - 1, 1 - 2 * ViewportUV.y);
}

vec2 ScreenPosToViewportUV(vec2 ScreenPos)
{
    return vec2(0.5 + 0.5 * ScreenPos.x, 0.5 - 0.5 * ScreenPos.y);
}
]]

_G.ShaderFunction.LightFunc = [[
vec3 LightDiffuseColor(vec3 LightColor, vec3 LightDir, vec3 WorldNormal)
{
    return LightColor * max(0, dot(-LightDir, WorldNormal));
} 

vec3 LightSpecularColorPhong(vec3 LightColor, vec3 LightDir, vec3 WorldNormal, vec3 Viewdir)
{
    vec3 RL = reflect(-LightDir, WorldNormal);  //Reflection vector
    float spec = pow(max(dot(Viewdir, RL), 0.0), 32);
    vec3 SpecularColor = LightColor * spec;
    return SpecularColor;
} 
]]

_G.ShaderFunction.Common = [[
    uniform mat4 Inverse_ProjectviewMatrix;

    vec2 ViewportUVToScreenPos(vec2 ViewportUV)
    {
        return vec2(2 * ViewportUV.x - 1, 1 - 2 * ViewportUV.y);
    }

    vec2 ScreenPosToViewportUV(vec2 ScreenPos)
    {
        return vec2(0.5 + 0.5 * ScreenPos.x, 0.5 - 0.5 * ScreenPos.y);
    }

    vec4 CacleWorldPosition(vec2 IntextureCoords, float InDepth)
    {
        vec2 uv = ViewportUVToScreenPos(IntextureCoords);
        vec4 vpos = vec4(uv.x, uv.y, InDepth, 1.0);

        vec4 spos = Inverse_ProjectviewMatrix * vpos;
        return spos;
    }
]]
