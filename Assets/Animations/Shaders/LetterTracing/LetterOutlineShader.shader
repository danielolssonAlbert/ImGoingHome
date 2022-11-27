Shader "Unlit/LetterOutlineShader"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        Cull Off
        Lighting Off
        ZWrite Off

        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _regularCompletedColor;
            fixed4 _regularNotCompletedColor;
            fixed4 _outlineCompletedColor;
            fixed4 _outlineNotCompletedColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uv.z = v.uv.z;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mask = tex2D(_MainTex, i.uv);

                fixed4 regularColor = lerp(_regularNotCompletedColor, _regularCompletedColor, i.uv.z);
                fixed4 outlineColor = lerp(_outlineNotCompletedColor, _outlineCompletedColor, i.uv.z);

                return (mask.r * regularColor + mask.g * outlineColor) * mask.a;
            }
            ENDCG
        }
    }
}
