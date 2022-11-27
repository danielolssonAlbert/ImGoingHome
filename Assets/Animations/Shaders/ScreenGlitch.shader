Shader "Custom/ScreenGlitch" {
	Properties{
		//_TintColor("Tint Color", Color) = (0,0.5,1,1)
		_TintColorBase("Tint Color Base", Color) = (0,0.5,1,0.1)
		[Header(texures)]
	    _MainTex("Main texure", 2D) = "white" {}
		_MaskTex("Mask texure", 2D) = "white" {}
		[Header(GlitchEffect)]
		[Toggle(GLITCH)]
        _Glitch ("ChrAbberation", Float) = 0
		_GlitchTime("Glitches Over Time", Range(0.01,2)) = 1.0
		[Header(ChromaticAbberation)]
         [Toggle(CHROMATICABBERATION)]
        _ChrAbb ("ChrAbberation", Float) = 0
		_SmallScanlineSize ("SmallScanlineSize", Float) = 30
		_Time_1 ("Time_1", Float) = 0
		_BigScanlineSize ("BigScanlineSize", Float) = 0
		_Time_2 ("Time_2", Float) = 0
		
		//_ChrAbbPower("ChrAbberationPower", Range(0.0,0.06)) = 0.01
	}

		Category{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Sphere" }
		Blend One One
		ColorMask RGB
		Cull Off 
		SubShader{
		Pass{

		CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #pragma shader_feature CHROMATICABBERATION
		#pragma shader_feature GLITCH


        #include "UnityCG.cginc"

	sampler2D _MainTex, _MaskTex;
	fixed4 _TintColor, _TintColorBase;
	


	struct appdata_t {
		float4 vertex : POSITION;
		fixed4 color : COLOR;

		float2 texcoord : TEXCOORD0;
		float2 maskcoord : TEXCOORD2;
		float3 normal : NORMAL; // vertex normal
		//UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct v2f {
		float4 vertex : SV_POSITION;
		fixed4 color : COLOR;
		float2 texcoord : TEXCOORD0;
		float2 maskcoord : TEXCOORD2;
		float3 wpos : TEXCOORD1; // worldposition
		
	};

	float4 _MainTex_ST, _MaskTex_ST;
	float _GlitchTime;
	float _WorldScale;
	float _OptTime = 0;
	float _ChrAbbPower;
	float _SmallScanlineSize;
	float _BigScanlineSize, _Time_1, _Time_2;
    

	//RandomValue function
	float rand(float3 co)
    {
      return frac(sin( dot(co.xyz ,float3(12.9898,10.233,5.5432*_SinTime.y) )) * 4.5453);
    }
//////////////////////////////////////////////////////////////////////////////////////
	v2f vert(appdata_t v)
	{
		v2f o;

		o.vertex = UnityObjectToClipPos(v.vertex);

		// Vertex glitching
		#ifdef GLITCH
		_OptTime = _OptTime == 0 ? sin(_Time.w * _GlitchTime) : _OptTime;// optimisation
		float glitchtime = step(0.99, _OptTime); // returns 1 when sine is near top, otherwise returns 0;
		float glitchPos = v.vertex.y + _SinTime.y;// position on model
		float glitchPosClamped = step(0, glitchPos) * step(glitchPos, 0.3);// clamped segment of model
		o.vertex.zx +=  glitchPosClamped* 0.03 * glitchtime * _SinTime.y;// moving the vertices when glitchtime returns 1;
		#endif


		o.color = v.color;
		o.color.a = _TintColorBase.a;
		o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
		o.maskcoord = TRANSFORM_TEX(v.maskcoord,_MaskTex);

		// world position and normal direction
		o.wpos = mul(unity_ObjectToWorld, v.vertex).xyz;
		

		return o;
	}

 
//////////////////////////////////////////////////////////////////////////////////////
	fixed4 frag(v2f i) : SV_Target
	{
		float4 tex = tex2D(_MainTex, i.texcoord)  ;// texure
		float4 mask = tex2D(_MaskTex, i.maskcoord);//mask texure


		//ChromaticAbberation Glitch
		#ifdef CHROMATICABBERATION
		_OptTime = _OptTime == 0 ? (tan(_Time.y + rand(5) ))*0.08 : _OptTime;
		float2 glitchtime_1 = step(0.9, _OptTime);
		tex.b = tex2D(_MainTex, i.texcoord - (glitchtime_1) * 0.1).b ;
		tex.g = tex2D(_MainTex, i.texcoord + (glitchtime_1) * 0.1).g;
        #endif
		
		//BigScanline
		mask.g = tex2D(_MaskTex, float2 (i.maskcoord.x, i.maskcoord.y * _BigScanlineSize- _Time.y*_Time_2)).g;
		//SmallScanline
		mask.r = tex2D(_MaskTex, float2 (i.maskcoord.x, i.maskcoord.y*_SmallScanlineSize + _Time.y*_Time_1)).r;
        //ClipMask BigScanline & SmallScanline    
		mask.g *= mask.b;
		mask.r *= mask.b;


		fixed4 col = tex + mask.g + mask.b * 0.5 + mask.r;// end result color 
		
	
		return col *  _TintColorBase;
		}
		ENDCG
	}
	}
	}
}