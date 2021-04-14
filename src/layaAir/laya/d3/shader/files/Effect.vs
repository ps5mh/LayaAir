#if defined(GL_FRAGMENT_PRECISION_HIGH)// 原来的写法会被我们自己的解析流程处理，而我们的解析是不认内置宏的，导致被删掉，所以改成 if defined 了
	precision highp float;
#else
	precision mediump float;
#endif
#include "Lighting.glsl";
#include "LayaUtile.glsl";

attribute vec4 a_Position;
attribute vec4 a_Color;
attribute vec2 a_Texcoord0;

#ifdef GPU_INSTANCE
	uniform mat4 u_ViewProjection;
	attribute mat4 a_WorldMat;
#else
	uniform mat4 u_MvpMatrix;
#endif

#ifdef COLOR
	varying vec4 v_Color;
#endif

#ifdef _SCROLL2TEXBLEND_ON
varying vec4 v_Texcoord0;
#else
varying vec2 v_Texcoord0;
#endif

uniform vec4 u_TilingOffset;

#ifdef _SCROLL2TEXBLEND_ON
	// uniform vec4 _MainTex_ST;
	uniform vec2 _MainTex_Scroll;
	uniform vec4 _SubTex_ST;
	uniform vec2 _SubTex_Scroll;
	uniform float u_Time;
#endif

#ifdef BONE
	const int c_MaxBoneCount = 24;
	attribute vec4 a_BoneIndices;
	attribute vec4 a_BoneWeights;
	uniform mat4 u_Bones[c_MaxBoneCount];
#endif


void main()
{
	vec4 position;
	#ifdef BONE
		mat4 skinTransform;
	 	#ifdef SIMPLEBONE
			float currentPixelPos;
			#ifdef GPU_INSTANCE
				currentPixelPos = a_SimpleTextureParams.x+a_SimpleTextureParams.y;
			#else
				currentPixelPos = u_SimpleAnimatorParams.x+u_SimpleAnimatorParams.y;
			#endif
			float offset = 1.0/u_SimpleAnimatorTextureSize;
			skinTransform =  loadMatFromTexture(currentPixelPos,int(a_BoneIndices.x),offset) * a_BoneWeights.x;
			skinTransform += loadMatFromTexture(currentPixelPos,int(a_BoneIndices.y),offset) * a_BoneWeights.y;
			skinTransform += loadMatFromTexture(currentPixelPos,int(a_BoneIndices.z),offset) * a_BoneWeights.z;
			skinTransform += loadMatFromTexture(currentPixelPos,int(a_BoneIndices.w),offset) * a_BoneWeights.w;
		#else
			skinTransform =  u_Bones[int(a_BoneIndices.x)] * a_BoneWeights.x;
			skinTransform += u_Bones[int(a_BoneIndices.y)] * a_BoneWeights.y;
			skinTransform += u_Bones[int(a_BoneIndices.z)] * a_BoneWeights.z;
			skinTransform += u_Bones[int(a_BoneIndices.w)] * a_BoneWeights.w;
		#endif
		position=skinTransform*a_Position;
	 #else
		position=a_Position;
	#endif
	#ifdef GPU_INSTANCE
		gl_Position = u_ViewProjection * a_WorldMat * position;
	#else
		gl_Position = u_MvpMatrix * position;
	#endif
	
	v_Texcoord0.xy=TransformUV(a_Texcoord0,u_TilingOffset);
	#ifdef _SCROLL2TEXBLEND_ON
		v_Texcoord0.zw=TransformUV(a_Texcoord0,_SubTex_ST);
		v_Texcoord0 += fract(vec4(_MainTex_Scroll.x, -_MainTex_Scroll.y, _SubTex_Scroll.x, -_SubTex_Scroll.y) * u_Time * 0.05);
	#endif
	#ifdef COLOR
		v_Color = a_Color;
	#endif
	gl_Position=remapGLPositionZ(gl_Position);
}