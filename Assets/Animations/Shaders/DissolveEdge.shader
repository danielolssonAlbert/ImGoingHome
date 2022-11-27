Shader "Custom/Dissolve Edge"
{
	Properties
	{
		[Enum(Off,0,Front,1,Back,2)] _CullMode ("Culling Mode", int) = 0
		[Enum(Off,0,On,1)] _ZWrite("ZWrite", int) = 0
		_PixelSample("PixelSample",Range(500,0)) = 60
		_Progress("Progress",Range(0,1)) = 0
		_Posterize("Posterize Main Texture", Range(100,0)) = 0
		[Space (20)]_MainTex("Main Texture", 2D) = "white" {}
		_MaskTex("Mask Texture", 2D) = "white" {}
		_DissolveTex("Dissolve Texture", 2D) = "white" {}

        [Space][Header(Distort Texture Setup)]
		_DistortTex("Distortion Texture", 2D) = "white" {}
		_distortPower("Distort Power",Range(0,1)) = 0
		_distorScale("Distort Scale",Range(0,3)) = 0
		_speedRotation("Speed Rotation",Range(0,100)) = 0
		[Space (20)]
		_Edge("Edge",Range(0.001,0.5)) = 0.01
		_Color("Color", Color) = (1, 0, 1, 1)
		

		[Header(Edge Color)]
		[Toggle(EDGE_COLOR)] _UseEdgeColor("Edge Color?", Float) = 1
		[HideIfDisabled(EDGE_COLOR)][NoScaleOffset] _EdgeAroundRamp("Edge Ramp", 2D) = "white" {}
		[HideIfDisabled(EDGE_COLOR)]_EdgeAround("Edge Color Range",Range(0,0.5)) = 0
		[HideIfDisabled(EDGE_COLOR)]_EdgeAroundPower("Edge Color Power",Range(1,5)) = 1
		[HideIfDisabled(EDGE_COLOR)]_EdgeAroundHDR("Edge Color HDR",Range(1,3)) = 1
		[HideIfDisabled(EDGE_COLOR)]_EdgeDistortion("Edge Distortion",Range(0,1)) = 0
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "CanUseSpriteAtlas" = "True" }

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha //Alpha Blend
			Cull[_CullMode] Lighting Off ZWrite[_ZWrite]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature EDGE_COLOR

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float3 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				float2 uv3 : TEXCOORD3;
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			sampler2D _MainTex;
			sampler2D _MaskTex;
			sampler2D _DissolveTex, _DistortTex;
			float4 _MainTex_ST;
			float4 _DissolveTex_ST, _DistortTex_ST;
			fixed _Edge;
			fixed _Progress;
			fixed4 _Color;
			fixed4 _MaskTex_ST;
			float _PixelSample, _distortPower, _distorScale, _speedRotation, _Posterize;

			#ifdef EDGE_COLOR
				sampler2D _EdgeAroundRamp;
				fixed _EdgeAround;
				float _EdgeAroundPower;
				float _EdgeAroundHDR;
				fixed _EdgeDistortion;
			#endif

			void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
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
			void Unity_Posterize(float4 In, float4 Steps, out float4 Out)
             {
                Out = floor(In / (1 / Steps)) * (1 / Steps);
             }
			
			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				//o.uv.z = v.uv.z;
				//v.uv.z = 1.0;
				o.uv2 = TRANSFORM_TEX(v.uv2, _DistortTex);
				o.uv1 = TRANSFORM_TEX(v.uv1, _MaskTex);
				o.uv3 = TRANSFORM_TEX(v.uv, _DissolveTex);
				o.color = v.color;
				//o.color.a *= v.uv.z;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				    //Pixalation image
				    float2 uv = floor(i.uv*_PixelSample)/_PixelSample;
					float2 uv1 = floor(i.uv1*_PixelSample)/_PixelSample;
					float2 uv2 = floor(i.uv2*_PixelSample)/_PixelSample;
					float2 uv3 = floor(i.uv3*_PixelSample)/_PixelSample;
                    
					//Rotate distort texture
                    float rotate = _Time*_speedRotation*100;
					Unity_Rotate_Degrees_float(i.uv2, float2(0.5,0.5),rotate,i.uv2);
	                fixed4 mainDistort = tex2D(_DistortTex, float2(i.uv2)* _distorScale);
					
					

                    fixed4 col = tex2D(_DissolveTex, i.uv3);
					fixed4 mask = tex2D(_MaskTex, i.uv1);
					mask.a *= mask.b;
				    fixed x = col.r;
					fixed progress = i.color.a;
	
					//Edge
					fixed edge = lerp( x + _Edge, x - _Edge, progress);
					fixed alpha = smoothstep(  progress + _Edge, progress - _Edge, edge);
					
					#ifdef EDGE_COLOR
						//Edge Around Factor
						fixed edgearound = lerp( x + _EdgeAround, x - _EdgeAround, progress);
						edgearound = smoothstep( progress + _EdgeAround, progress - _EdgeAround, edgearound);
						edgearound = pow(edgearound, _EdgeAroundPower);

						//Edge Around Distortion
						fixed avoid = 0.15;
						fixed distort = edgearound*alpha*avoid;
						float2 cuv = lerp( uv, uv + distort - avoid, progress * _EdgeDistortion);
						col = tex2D(_MainTex, cuv + mainDistort*_distortPower)*mask;
						col *= _Color;
						//Posterize main texture
						Unity_Posterize(col,_Posterize,col);
						
						col.rgb *= i.color.rgb;

						//Edge Around Color
						fixed3 ca = tex2D(_EdgeAroundRamp, fixed2(1-edgearound, 0)).rgb;
						ca = (col.rgb + ca)*ca*_EdgeAroundHDR;
						col.rgb = lerp( ca, col.rgb, edgearound);
						
					#else
						col = tex2D(_MainTex, uv);
						col.rgb *= i.color.rgb;
					#endif
                    
					col.a *= alpha;
					
					

					return col;
			}
			ENDCG
		}
	}
}
