#ifndef SHADER_PROMT_INCLUDED
    #define SHADER_PROMT_INCLUDED

    //FORMAT OF PROPERTIES
    _Color ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
    _MainTex ("MainTexture", 2D) = "white" {}
    _Offset("Offset Texture Y", Range(-1,1)) = 0
    _Rotation("Rotation Texture", float) = 0
    _ExampleName ("Texture2DArray display name", 2DArray) = "" {} 
    //https://www.youtube.com/watch?v=Q60cdwZDyjE, https://docs.unity3d.com/Manual/class-Texture2DArray.html

    [KeywordEnum(Dodge, LinearDodge, HardLight)] 
    _Blend("Blend Mode", Float) = 0

    [Toggle(APPLYTEXTURE2_ON)] 
    _ApplyMainTex2("Apply MainTexture_2", Float) = 0
    [HideIfDisabled(APPLYTEXTURE2_ON)] _ColorTex ("Solid color texture",Color) = (1,1,1,1)
    #if defined(APPLYTEXTURE2_ON)
    #endif
    //in the pass you should add #pragma shader_feature APPLYTEXTURE2_ON

    [Header(MAIN TEXTURE)]
    [Space(20)]
    [HideInInspector]
    [PerRendererData]
    [NoScaleOffset] //Tells the Unity Editor to hide tiling and offset fields for this texture property.
    [HDR]
    
    

    SUBSHADER
    TAGS
    {
        "Queue" = "Transparent"
        "IgnoreProjector" = "True"
        "RenderType" = "Transparent"
        "PreviewType" = "Plane"
        "CanUseSpriteAtlas" = "True"
    }
    
    //Sets which polygons the GPU should cull relative to the camera
    Cull Off, Back, Front 

    Lighting Off
    //Sets the depth bias on the GPU. It helps avoid z-fight
    Offset <factor(-1, 1)>, <units(-1, 1)>

    /*Sets whether the depth buffer contents are updated during rendering. 
    Normally, ZWrite is enabled for opaque objects and disabled for semi-transparent ones*/
    ZWrite Off, On
    
    //Sets the conditions under which geometry passes or fails depth testing.
    ZTest Less, LEqual(Default), Equal, GEqual, Greater, NotEqual, Always 
    

    // Blending your shader with the background 
    Blend SrcAlpha OneMinusSrcAlpha // Traditional transparency
    Blend One OneMinusSrcAlpha // Premultiplied transparency
    Blend One One // Additive
    Blend OneMinusDstColor One // Soft additive
    Blend DstColor Zero // Multiplicative
    Blend DstColor SrcColor // 2x multiplicative 
    
    // Grab backround and record in a texture
    //It's not work in URP and HDRP https://www.youtube.com/watch?v=nT57Sh0cIZI
    GrabPass {}
    GrabPass { "ExampleTextureName" }

    float4 gradWave = lerp(_Color_0, _Color_1, clamp((IN.texcoord.x-_GradientOffset)/_GradientSpread,0,1));//allow to create gradient along uv.x with offset and spread
    
#endif