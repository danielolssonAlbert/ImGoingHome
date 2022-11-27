#ifndef FUNCTIONS_LUCH_INCLUDED
    #define FUNCTIONS_LUCH_INCLUDED

    
    half BlurHD_G(half bhqp, half x)
    {
        return exp(-(x * x) / (2.0 * bhqp * bhqp));
    }
    half4 BlurHD(half2 uv, sampler2D source, half Intensity, half xScale, half yScale)
    {
        int iterations = 40.0;
        int halfIterations = iterations * 0.5;
        half sigmaX = 0.1 + Intensity * 0.5;
        half sigmaY = sigmaX;
        half total = 0.0;
        half4 ret = half4(0.0, 0.0, 0.0, 0.0);
        for (int iy = 0; iy < iterations; ++iy)
        {
            half fy = BlurHD_G(sigmaY, half(iy) -half(halfIterations));
            half offsetY = half(iy - halfIterations) * 0.00390625 * xScale;
            for (int ix = 0; ix < iterations; ++ix)
            {
                half fx = BlurHD_G(sigmaX, half(ix) - half(halfIterations));
                half offsetX = half(ix - halfIterations) * 0.00390625 * yScale;
                total += fx * fy;
                ret += tex2D(source, uv + half2(offsetX, offsetY)) * fx * fy;
            }
        }
        return ret / total;
    }
    //-----------------------------------------------------------------------
    //It rotates a texture around the center
    inline void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
    {
        Rotation = Rotation * (3.1415926f/180.0f);
        UV -= Center;
        float s = sin(Rotation);
        float c = cos(Rotation);
        float2x2 rMatrix = float2x2(c, -s, s, c);
        rMatrix *= 0.5;
        rMatrix += 0.5;
        rMatrix = rMatrix * 2 - 1;
        UV.xy = mul(UV.xy, rMatrix);
        UV += Center;
        Out = UV;
    }

    inline void Gradient(float4 Color_0, float4 Color_1, float texCoord, float GradientOffset, float GradientSpread, out float4 Out)
    {
        Out = lerp(Color_0, Color_1, clamp((texCoord - GradientOffset) / GradientSpread,0,1));
    }

    inline void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
    {
        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
    }
    float invLerp(float from, float to, float value)
    {
        return (value - from) / (to - from);
    }

    float remap(float origFrom, float origTo, float targetFrom, float targetTo, float value)
    {
        float rel = invLerp(origFrom, origTo, value);
        return lerp(targetFrom, targetTo, rel);
    }
    
    
    //Pixelization of a texture
    inline void Pixelization_tex(float2 uv,float PixelSample, out float2 outuv)
    {
        uv = floor(uv*PixelSample)/PixelSample;
        outuv = uv;

    }

    //Posterization a texture           
    inline void Unity_Posterize(float4 In, float4 Steps, out float4 Out)
    {
        Out = floor(In / (1 / Steps)) * (1 / Steps);
    }

    //Creation polar uv coordinates around the center           
    inline void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
    {
        float2 delta = UV - Center;
        float radius = length(delta) * 2 * RadialScale;
        float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
        Out = float2(radius, angle);
    }

    //Blend textures with background or another texture like in
    inline void Unity_Blend_Dodge_float4(float3 Base, float3 Blend, float Opacity, out float3 Out)
    {
        Out = Base / (1.0 - Blend);
        Out = lerp(Base, Out, Opacity);
    }
    
    inline void Unity_Blend_LinearDodge_float4(float3 Base, float3 Blend, float Opacity, out float3 Out)
    {
        Out = Base + Blend;
        Out = lerp(Base, Out, Opacity);
    }

    inline void Unity_Blend_HardLight_float4(float3 Base, float3 Blend, float Opacity, out float3 Out)
    {
        float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
        float3 result2 = 2.0 * Base * Blend;
        float3 zeroOrOne = step(Blend, 0.5);
        Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
        Out = lerp(Base, Out, Opacity);
    }

    void Unity_Blend_Overlay_float4(float3 Base, float3 Blend, float Opacity, out float3 Out)
    {
        float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
        float3 result2 = 2.0 * Base * Blend;
        float3 zeroOrOne = step(Base, 0.5);
        Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
        Out = lerp(Base, Out, Opacity);
    }

    void Unity_Blend_VividLight_float4(float3 Base, float3 Blend, float Opacity, out float3 Out)
    {
        float3 result1 = 1.0 - (1.0 - Blend) / (2.0 * Base);
        float3 result2 = Blend / (2.0 * (1.0 - Base));
        float3 zeroOrOne = step(0.5, Base);
        Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
        Out = lerp(Base, Out, Opacity);
    }
    void Unity_Blend_PinLight_float4(float3 Base, float3 Blend, float Opacity, out float3 Out)
    {
        float3 check = step (0.5, Blend);
        float3 result1 = check * max(2.0 * (Base - 0.5), Blend);
        Out = result1 + (1.0 - check) * min(2.0 * Base, Blend);
        Out = lerp(Base, Out, Opacity);
    }
    void Unity_Blend_HardMix_float4(float3 Base, float3 Blend, float Opacity, out float3 Out)
    {
        Out = step(1 - Base, Blend);
        Out = lerp(Base, Out, Opacity);
    }
    void Unity_Blend_Screen_float4(float3 Base, float3 Blend, float Opacity, out float3 Out)
    {
        Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
        Out = lerp(Base, Out, Opacity);
    }

    void Unity_Blend_SoftLight_float4(float3 Base, float3 Blend, float Opacity, out float3 Out)
    {
        float3 result1 = 2.0 * Base * Blend + Base * Base * (1.0 - 2.0 * Blend);
        float3 result2 = sqrt(Base) * (2.0 * Blend - 1.0) + 2.0 * Base * (1.0 - Blend);
        float3 zeroOrOne = step(0.5, Blend);
        Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
        Out = lerp(Base, Out, Opacity);
    }


    void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
    {
        Out = normalize(float3(A.rg + B.rg, A.b * B.b));
    }   

    void GrayscaleColor(float3 color, out float3 grayscale)
    {
        grayscale = dot(color.rgb, float3(0.3, 0.59, 0.11));
    }



#endif