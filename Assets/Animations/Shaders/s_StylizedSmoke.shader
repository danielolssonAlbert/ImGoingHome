Shader "Albert/StylizedSmoke"
{
	Properties
	{
		[Enum(Off,0,Front,1,Back,2)] _CullMode ("Culling Mode", int) = 0
		[Enum(Off,0,On,1)] _ZWrite("ZWrite", int) = 0
		
		_Progress("Progress",Range(0,1.0)) = 0
		
		[Space (20)]_MainTex("Main Texture", 2D) = "white" {}
		_MaskTex("Mask of Distortion", 2D) = "white" {}
		_DissolveTex("Dissolve Texture", 2D) = "white" {}

		[Space(20)][Header(Distort Texture Setup)]
		_DistortTex("Distortion Texture", 2D) = "white" {}
		_distortPower("Distort Power",Range(0,1)) = 0
		_distorScale("Distort Scale",Range(0,3)) = 0
		_speedRotation("Speed Rotation",Range(0.0,100)) = 0 

		[Space (20)]
		_Edge("Edge",Range(0.001,0.5)) = 0.01
		_Color("Color", Color) = (1.0, 0.0, 1.0, 1.0)
		

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
			Cull[_CullMode] 
			Lighting Off 
			ZWrite[_ZWrite]

			CGPROGRAM
			#pragma vertex VertexMain
			#pragma fragment FragmentMain
			#pragma shader_feature EDGE_COLOR

			#include "UnityCG.cginc"
			#include "CgincLibraries\FunctionsLuch.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 uv : TEXCOORD0;
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

			sampler2D _MainTex, _DissolveTex, _DistortTex, _MaskTex;
			float4 _MainTex_ST, _DissolveTex_ST, _DistortTex_ST, _Color;
			fixed4 _MaskTex_ST;
			fixed _Edge, _Progress;
			float _PixelSample, _distortPower, _distorScale, _speedRotation, _Posterize;

			#ifdef EDGE_COLOR
				sampler2D _EdgeAroundRamp;
				float _EdgeAroundHDR, _EdgeAroundPower;
				fixed _EdgeDistortion, _EdgeAround;
			#endif

			
			
			
			v2f VertexMain (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.z = v.uv.z;//streaming from particles

				o.uv1 = TRANSFORM_TEX(v.uv, _MaskTex);
				o.uv2 = TRANSFORM_TEX(v.uv, _DistortTex);
				o.uv3 = TRANSFORM_TEX(v.uv, _DissolveTex);
				o.color = v.color;
				
				return o;
			}
			
			fixed4 FragmentMain (v2f i) : SV_Target
			{
				
				
				//Rotate distort texture
				float rotate = _Time*_speedRotation*-100;
				Unity_Rotate_Degrees_float(i.uv2, float2(0.5,0.5),rotate,i.uv2);
				//Mask Texture
				fixed4 mask = tex2D(_MaskTex, i.uv1);
				
				//Distort Texture
				fixed4 mainDistort = tex2D(_DistortTex, float2(i.uv2)* _distorScale)*_distortPower;
				//restricting influence of the Distortion
				mainDistort*=mask.r;
				
				
				//Dissolve Texture. Distortion of the Dissolve Texture
				fixed4 dissolveTex = tex2D(_DissolveTex, i.uv3+mainDistort);
				
				fixed x = dissolveTex.r;
				fixed progress = i.uv.z;
				
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
					float2 cuv = lerp( i.uv, i.uv + distort - avoid, progress * _EdgeDistortion);
					float4 mainTex = tex2D(_MainTex, cuv + mainDistort*_distortPower);
					
					
					mainTex.a*=alpha;
					mainTex.a *= i.color.a;
					mainTex.rgb *= i.color.rgb;

					//Edge Around Color
					fixed3 ca = tex2D(_EdgeAroundRamp, fixed2(1-edgearound, 0)).rgb;
					ca = (mainTex.rgb + ca)*ca*_EdgeAroundHDR;
					mainTex.rgb = lerp( ca, mainTex.rgb, edgearound);
					
				#else
					float4 mainTex = tex2D(_MainTex, i.uv);
					
					mainTex.a*=alpha;
					
					
					//clip(mainTex.a - 0.7);
					mainTex.rgb *= i.color.rgb;
					
					mainTex.a *= i.color.a;
				#endif
				
				
				
				

				return mainTex;
			}
			ENDCG
		}
	}
}
