// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Albert/Alphabet"
{
    Properties
    {
        _MaskTex ("Mask Texture", 2D) = "white" {}
        
        
        _Wave ("Wave Texture", 2D) = "white" {}
        _DistortTex ("Distort Texture", 2D) = "white" {}
        _DistortPower("Power of Distortion", Range(0,2)) = 0
        _Speed("Speed of animation", Range(-5,5)) = 0
        _FillingLevel("Level of Filling", Range(0,1.5)) = 0
        _WaveColor ("Wave Color", Color) = (1,1,1,1)
        _LetterColor ("Letter Color", Color) = (1,1,1,1)
        _BackColor ("Back Color", Color) = (1,1,1,1)
        //[HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        
        
        // _Offset("Color?", Range(0,1)) = 0
        
        
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
        Blend One OneMinusSrcAlpha 
        

        Pass
        {
            CGPROGRAM
            #pragma vertex SpriteVert
            #pragma fragment SpriteFrag

            #include "UnityCG.cginc"
            #include "CgincLibraries/FunctionsLuch.cginc"




            struct appdata_t
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
                
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                float4 screenTexCoord : TEXCOORD1;
                
            };

            sampler2D _MaskTex, _Mask, _Wave, _DistortTex;
            float4 _MaskTex_ST, _Mask_ST, _Wave_ST, _DistortTex_ST;
            fixed4 _WaveColor, _LetterColor, _BackColor;
            float4 _ColorTex;
            fixed _Offset;
            float _FillingLevel, _DistortPower, _Speed;

            v2f SpriteVert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = IN.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.vertex);
                OUT.texcoord = TRANSFORM_TEX(IN.texcoord,_MaskTex);
                OUT.texcoord = TRANSFORM_TEX(IN.texcoord,_Wave);
                OUT.screenTexCoord = ComputeScreenPos(OUT.vertex);
                
                return OUT;
            }

            fixed4 SpriteFrag(v2f IN) : SV_Target
            {
                //adjusting screen texture coordinates
                float2 scrTexCoord = IN.screenTexCoord.xy/IN.screenTexCoord.w;
                float aspect = _ScreenParams.x / _ScreenParams.y;
                scrTexCoord.x *= aspect;
                scrTexCoord = TRANSFORM_TEX(scrTexCoord, _DistortTex);
                // Distortion texture
                fixed4 distortion = tex2D (_DistortTex, float2(scrTexCoord.x + _Time.x*_Speed, scrTexCoord.y));
                //Wave texture
                float UVy = lerp(0.23,-0.65,_FillingLevel);
                fixed4 waveTex = tex2D(_Wave, float2(IN.texcoord.x,IN.texcoord.y+UVy)+distortion *_DistortPower) * _WaveColor;
                
                //The Main mask texture
                fixed4 maskLetter = tex2D (_MaskTex, IN.texcoord);

                //Outnline of the letter
                _LetterColor *= maskLetter.r; 

                //Creating a mask for the wave texture 
                fixed maskWave = maskLetter.b - maskLetter.g;
                waveTex *= maskWave;
                //Back of the letter
                _BackColor *= ((1-maskLetter.g)*(maskWave-waveTex.a));
                waveTex *= 1-_BackColor.a;
                
                
                fixed4 result =  _BackColor.rgba + _LetterColor.rgba + waveTex.rgba;
                result *= 1-maskLetter.g;
                
                return result;
            }
            ENDCG
            
        }
    }
}
