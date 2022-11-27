// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Albert/2DWaterWave"
{
    Properties
    {        
        [Header(Wave Setup)]
        [Space(10)]
        _FillingLevel("Level of Filling", Range(0,1)) = 0
        _WaveSpread("Wave Spread", Range(0,0.2)) = 0
        _WaveTransparency("Wave Transparancy", Range(0,1)) = 0

        [Space(10)]
        [Header(Distortion(Liquid) Setup)]
        [Space(10)]
        _DistortTex ("Distort Texture", 2D) = "white" {}
        _DistortPower("Power of Distortion", Range(0,0.5)) = 0
        _Speed("Speed of animation", Range(-5,5)) = 0

        [Space(10)]
        [Header(Mask of Influence of Distortion(Liquid) Setup)]
        [Space(10)]
        _HeightMask("Height of Mask", Range(0,1)) = 0
        _MaskSpread("Mask Spread", Range(0,1)) = 0
        _InvertMaskON("Invert Mask? 0-NO 1-YES", Range(0,1)) = 0
        //[Toggle(_INVERT_MASK_ON)] _InvertMaskON("Invert Mask?", Float) = 0
        
        [Space(10)]
        [Header(Color Wave Setup)]
        [Space(10)]
        _Color_1 ("Color_1", Color) = (1,1,1,1)
        _Color_0 ("Color_0", Color) = (1,1,1,1)
        _GradientOffset("Gradient Offset", Range(-1,1)) = 0
        _GradientSpread("Gradient Spread", Range(0,2)) = 0

        [Space(10)]
        [Toggle(_DISTORT_GRADIENT_ON)] _DistortGradientON("Distort Gradient?", Float) = 0
        [Toggle(_POSTERIZE_ON)] _PosterizeON("Posterization?", Float) = 0

        _Step("Step of posterization", Range(0,30)) = 0                
        
        
        
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        

        Pass
        {
            CGPROGRAM
            #pragma vertex SpriteVert 
            #pragma fragment SpriteFrag
            #pragma shader_feature _DISTORT_GRADIENT_ON 
            #pragma shader_feature _POSTERIZE_ON 
            #pragma shader_feature _INVERT_MASK_ON
            #include "UnityCG.cginc"
            #include "CgincLibraries\FunctionsLuch.cginc"




            struct appdata_t //cpu-->gpu
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
               
                
            };

            struct v2f //vertex-->fragment
            {
                float4 vertex   : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                
                
            };

            sampler2D  _Wave, _DistortTex;
            float4  _Color_0, _Color_1, _Wave_ST, _DistortTex_ST;
            float4 _ColorTex;
            fixed _Offset, _GradientOffset, _GradientSpread, _WaveTransparency,_Edge, _WaveSpread;
            fixed _HeightMask, _MaskSpread;
            float _FillingLevel, _DistortPower,_Step, _Speed,_InvertMaskON;

            v2f SpriteVert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = IN.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.texcoord1 = float2(_Time.x*_Speed, 0)+ (TRANSFORM_TEX(IN.texcoord, _DistortTex));
                

                
                
                
                return OUT;
            }

            fixed4 SpriteFrag(v2f IN) : SV_Target
            {
                
                // Distortion texture
                fixed4 distortion = tex2D (_DistortTex, IN.texcoord1)*_DistortPower;
                
            float4 distortionMask = lerp(1 - _InvertMaskON, _InvertMaskON,clamp(((IN.texcoord.y) - _HeightMask+distortion)/_MaskSpread,0,1)) ;
            distortion*=distortionMask;
            
            
            fixed DistortGradient = 0;

            //Using a normal Gradient or to distort the gradient
            #if defined(_DISTORT_GRADIENT_ON)
                DistortGradient = distortion;
            #endif
            //Gradient should follow for the FillingLevel
            _GradientOffset-=_FillingLevel;
            //Color of Wave texture
            float4 gradWave = lerp(_Color_0, _Color_1, clamp((IN.texcoord.y+(_GradientOffset))/_GradientSpread+DistortGradient,0,1)+DistortGradient);
            //Wave texture
            float4 waveTex = lerp(1, 0,clamp(((IN.texcoord.y+ distortion) - _FillingLevel+DistortGradient)/_WaveSpread,0,1)) ;
            
            
            gradWave.a*=waveTex.r;
            
            gradWave.a*=_WaveTransparency;
            
            
            #if defined(_POSTERIZE_ON)
                Unity_Posterize(gradWave,_Step,gradWave);
            #endif
            
            
            

            
            
            
            return gradWave;
        }
        ENDCG
        
    }
}
}
