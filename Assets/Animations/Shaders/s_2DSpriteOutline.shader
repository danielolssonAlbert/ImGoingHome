Shader "Albert/2DSpriteOutline"
{
    Properties
    {
        [HideInInspector][PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _OutlineTex ("Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1.0,1.0,1.0,1.0)

        _OutlineColor ("Outline Color", Color) = (1.0,1.0,1.0,1.0)
        _Width ("Width of Outline", Range(0.0,1.0)) = 1.0
        _Hardness ("Hardness of Outline", Range(0.0,1.0)) = 1.0

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

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
        Blend One OneMinusSrcAlpha


        Pass
        {
            CGPROGRAM
            #pragma vertex VertexMain
            #pragma fragment FragmentMain

            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float2 texcoord1  : TEXCOORD1;
            };

            sampler2D _MainTex, _OutlineTex, _AlphaTex;
            float4 _OutlineTex_ST;
            fixed4 _OutlineColor, _Color;
            fixed _GlowScale, _Width, _Hardness;



            v2f VertexMain(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.texcoord1 = TRANSFORM_TEX(IN.texcoord,_OutlineTex);
                OUT.color = IN.color * _Color;


                return OUT;
            }



            fixed4 FragmentMain(v2f IN) : SV_Target
            {
                // Use alpha assuming glow is a gradient from 0.0 to ~0.75% alpha, and the rest is the sprite.
                float4 mainTex = tex2D (_MainTex, IN.texcoord);


                float4 outlineTex = tex2D (_OutlineTex,IN.texcoord1) ;
                float silhouette = mainTex.a + mainTex.b;
                mainTex.b*=mainTex.a;

                //Determining edge of outline
                fixed Hardness = lerp(0.0,10.0,_Hardness);
                fixed Width = lerp(0.0,lerp(3.0,40.0,_Hardness),_Width);
                fixed edge = saturate(silhouette *Width-(Hardness));



                //Outline Alpha and Color
                fixed spriteAlpha = saturate(edge-saturate(mainTex.a*0.85));
                _OutlineColor *= spriteAlpha;
                _OutlineColor *=_OutlineColor.a;

                //Limiting Outline Texture by Outline Alpha
                outlineTex*=spriteAlpha;

                //Color of Main Texture
                mainTex.rgba*=IN.color.rgba;

                float4 result = mainTex + outlineTex * _OutlineColor;



                return result;
            }
            ENDCG
        }
    }
}