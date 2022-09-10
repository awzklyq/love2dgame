_G.ShaderFunction.GetPBRCode = [[

    const float PI = 3.14;
    float D_GGX_TR(vec3 N, vec3 H, float a)
    {
        float a2     = a*a;
        float NdotH  = max(dot(N, H), 0.0);
        float NdotH2 = NdotH*NdotH;

        float nom    = a2;
        float denom  = (NdotH2 * (a2 - 1.0) + 1.0);
        denom        = PI * denom * denom;

        return nom / denom;
    }

    float ndfGGX(float cosLh, float roughness)
    {
        float alpha   = roughness * roughness;
        float alphaSq = alpha * alpha;

        float denom = (cosLh * cosLh) * (alphaSq - 1.0) + 1.0;
        return alphaSq / (PI * denom * denom);
    }


    float G_SUB(vec3 N, vec3 V, float k)
    {
        float nv = max(dot(N, V), 0);

        return nv / ((nv * (1 - k)) + k);
    }

    float Geometric (float a, vec3 nor, vec3 viewdir, vec3 lightdir)
    {
        float k = ((a + 1) * (a + 1)) / 8;
        return G_SUB(nor, viewdir, k) * max(G_SUB(nor, lightdir, k), 0.0005);
    }

    vec3 fresnelSchlick(vec3 F0, vec3 H, vec3 V)
    {
        return F0 + (1.0 - F0) * pow(1.0 - dot(H, V), 5.0);
    }

    vec3 GetPBR(float Roughness, float metalness, vec3 F0, vec3 color, vec3 viewdir, vec3 lightdir, vec3 nor)
    {
        lightdir = -lightdir;

        vec3 h = normalize(viewdir + lightdir);

        float a = Roughness;
        float D = D_GGX_TR(nor, h, a);

        float G = Geometric(a, nor, viewdir, lightdir);
        
         F0 = mix(F0,  color , metalness);
        vec3 F = fresnelSchlick(F0, h, viewdir);
        //vec3 kd = mix(vec3(1.0) - F, vec3(0.0), metalness);
        float temp = max(4 * dot(viewdir, nor) * dot(lightdir, nor), 0.00001);

        vec3 Specular  = ((D * F * G ) / temp) ;//* color;//vec3(1);

        // kS is equal to Fresnel
        vec3 kS = F;
        vec3 kD = vec3(1.0) - kS;
        kD *= 1.0 - metalness;
        vec3 diffuse = kD * (color / PI);

        return Specular + diffuse;
    }
]]
_G.ShaderFunction.PBRFunctionName = "GetPBR"
