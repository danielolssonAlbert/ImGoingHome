Shader "Albert/2DSpriteEffects"
{
    Properties
    {
        [HideInInspector][PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _ShadowTex ("Shadow Texture", 2D) = "white" {}
        _ShadowX("Shadow X Axis", Range(-0.5, 0.5)) = 0.0
        _ShadowY("Shadow Y Axis", Range(-0.5, 0.5)) = 0.0
        _Color ("Shadow Color", Color) = (1.0,1.0,1.0,1.0)
        _SizeShadow("Size Shadow", Range(0.5, 3)) = 1.0
        [Toggle(SOFTSHADOW_ON)] 
        _SoftShadow("Soft Shadow", Float) = 0.0
        _BlurIntensity("BlurIntensity", Range(0.0, 100.0)) = 0.0 
        [Space(20)]
        _RectSize("Rect Size", Range(1.0, 4.0)) = 1.0
        
        
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
            #pragma vertex VertexMain
            #pragma fragment FragmentMain
            #pragma shader_feature SOFTSHADOW_ON
            
            #include "UnityCG.cginc"
            #include "CgincLibraries/FunctionsLuch.cginc"
            
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

            sampler2D _MainTex, _ShadowTex;
            float4 _Color;         
            half _RectSize,_ShadowX,  _ShadowY, _BlurIntensity;
            half _SizeShadow;
            
            
            
            v2f VertexMain(appdata_t IN)
            {
                v2f OUT;
                //rectsize
                IN.vertex.xy += (IN.vertex.xy * (_RectSize-1.0));
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color;
                
                return OUT;
            }
            
            fixed4 FragmentMain(v2f IN) : SV_Target
            {
                //rectsize
                IN.texcoord = IN.texcoord.xy * _RectSize + (-_RectSize*0.5+0.5); 
                //Main Texture
                float4 mainTex = tex2D (_MainTex, IN.texcoord)*IN.color;                               
                mainTex*=mainTex.a;
                _ShadowX = remap(0.5,-0.5,-1.5,0.5,_ShadowX);
                _ShadowY = remap(0.5,-0.5,-1.5,0.5,_ShadowY);
                 
                
                float2 scalingUV = IN.texcoord + float2(_ShadowX, _ShadowY);
                Unity_Remap_float2(scalingUV*1/_SizeShadow, float2 (-0.5, 0.5), float2 (0, 1),scalingUV);

                #if defined(SOFTSHADOW_ON)
                    //You need to add another tex as a shadow because BlurHD requires "sampler2D"
                    float4 shadow = BlurHD(scalingUV, _ShadowTex, _BlurIntensity, 1, 1)*_Color;
                    shadow*=saturate(1-mainTex.a);
                    float4 coloredShadow = shadow.a * _Color;
                    float4 result = mainTex + coloredShadow;
                #else
                    float4 shadow = tex2D(_ShadowTex, scalingUV).a* _Color;
                    shadow*=saturate(1-mainTex.a);
                    float4 result = mainTex + shadow;
                #endif
                
                
                
                return result;
            }
            ENDCG
        }
    }
}