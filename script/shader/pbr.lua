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

    vec3 GetPBR(float a, float metalness, vec3 color, vec3 viewdir, vec3 lightdir, vec3 nor)
    {
        //a = 0.1; // TODO
      //  metalness = 1; //TODO
        lightdir = -lightdir;
        //float ks = 1 - kd;
        vec3 h = normalize(viewdir + lightdir);
        float D = D_GGX_TR(nor, h, a);

        float G = Geometric(a, nor, viewdir, lightdir);

        vec3 F0 = vec3(0.4);
        
         F0 = mix(F0,  color * vec3(1), metalness);
        vec3 F = fresnelSchlick(F0, h, viewdir);
        vec3 kd = mix(vec3(1.0) - F, vec3(0.0), metalness);
        float temp = max(4 * dot(viewdir, nor) * dot(lightdir, nor), 0.00001);

        vec3 Specular  = ((D * F * G ) / temp) * vec3(1);

        vec3 diffuse = kd * color;//(color / PI);

        return (vec3(1) - kd) * Specular + kd * diffuse;
    }
]]
_G.ShaderFunction.PBRFunctionName = "GetPBR"
