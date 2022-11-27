// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Albert/UI/Alphabet"
{
    Properties
    {
        [PerRendererData] _MainTex ("Mask Texture", 2D) = "white" {}
        _Wave ("Wave Texture", 2D) = "white" {}
        _DistortTex ("Distort Texture", 2D) = "white" {}
        _DistortPower("Power of Distortion", Range(0,2)) = 0
        _Speed("Speed of animation", Range(-20,5)) = 0
        _FillingLevel("Level of Filling", Range(0,1.5)) = 0
        _WaveColor ("Wave Color", Color) = (1,1,1,1)
        _LetterColor ("Letter Color", Color) = (1,1,1,1)
        _BackColor ("Back Color", Color) = (1,1,1,1)


        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
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

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend One OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                half4  mask : TEXCOORD2;
                float4 screenTexCoord : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex, _Wave, _DistortTex;
            fixed4 _Color, _WaveColor, _LetterColor, _BackColor;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST, _Wave_ST, _DistortTex_ST;
            float _UIMaskSoftnessX, _FillingLevel, _Speed;
            float _UIMaskSoftnessY, _DistortPower;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                float4 vPosition = UnityObjectToClipPos(v.vertex);
                OUT.worldPosition = v.vertex;
                OUT.vertex = vPosition;

                float2 pixelSize = vPosition.w;
                pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));
                float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);

                

                OUT.texcoord = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _Wave);
                OUT.screenTexCoord = ComputeScreenPos(OUT.vertex);


                OUT.mask = half4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));
                OUT.color = v.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                //Round up the alpha color coming from the interpolator (to 1.0/256.0 steps)
                //The incoming alpha could have numerical instability, which makes it very sensible to
                //HDR color transparency blend, when it blends with the world's texture.
                const half alphaPrecision = half(0xff);
                const half invAlphaPrecision = half(1.0/alphaPrecision);
                IN.color.a = round(IN.color.a * alphaPrecision)*invAlphaPrecision;

                // Main texture
                half4 maskLetter = IN.color * (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd);

                //screen coordinates for distrortion texture
                float2 scrTexCoord = IN.screenTexCoord.xy/IN.screenTexCoord.w;
                float aspect = _ScreenParams.x / _ScreenParams.y;
                scrTexCoord.x *= aspect;
                scrTexCoord = TRANSFORM_TEX(scrTexCoord, _DistortTex);
                //Distortion texture 
                fixed4 distortion = tex2D (_DistortTex, float2(scrTexCoord.x + _Time.x*_Speed, scrTexCoord.y));

                //Wave texture
                float UVy = lerp(0.23,-0.65,_FillingLevel);
                fixed4 waveTex = tex2D(_Wave, float2(IN.texcoord.x,IN.texcoord.y+UVy)+ _TextureSampleAdd +distortion *_DistortPower) * _WaveColor;
                //Outline of the letter
                _LetterColor *= maskLetter.r; 

                //Creating a mask for the wave texture 
                fixed maskWave = maskLetter.b - maskLetter.g;
                waveTex *= maskWave;
                //Back of the letter
                _BackColor *= ((1-maskLetter.g)*(maskWave-waveTex.a));
                waveTex *= 1-_BackColor.a;

                fixed4 result =  _BackColor.rgba + _LetterColor.rgba + waveTex.rgba;
                result *= 1-maskLetter.g;


                #ifdef UNITY_UI_CLIP_RECT
                    half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
                    maskLetter.a *= m.x * m.y;
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                    clip (maskLetter.a - 0.001);
                #endif

                

                return result;
            }
            ENDCG
        }
    }
}
