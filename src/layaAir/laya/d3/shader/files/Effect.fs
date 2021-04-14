#if defined(GL_FRAGMENT_PRECISION_HIGH)// 原来的写法会被我们自己的解析流程处理，而我们的解析是不认内置宏的，导致被删掉，所以改成 if defined 了
	precision highp float;
#else
	precision mediump float;
#endif

#ifdef COLOR
	varying vec4 v_Color;
#endif

#ifdef _SCROLL2TEXBLEND_ON
	varying vec4 v_Texcoord0;
#else
	varying vec2 v_Texcoord0;
#endif

#ifdef MAINTEXTURE
	uniform sampler2D u_AlbedoTexture;
#endif

#ifdef SUBTEXTURE
	uniform sampler2D _SubTex;
	uniform float _SubTex_Perturbation;
#endif

#ifdef _ALPHATEST_ON
	uniform float _Cutoff;
#endif

uniform vec4 u_AlbedoColor;

#ifdef FOG
	uniform float u_FogStart;
	uniform float u_FogRange;
	#ifdef ADDTIVEFOG
	#else
		uniform vec3 u_FogColor;
	#endif
#endif

void main()
{
	vec4 color =  2.0 * u_AlbedoColor;
	#ifdef COLOR
		color *= v_Color;
	#endif
	#ifdef MAINTEXTURE
		color *= texture2D(u_AlbedoTexture, v_Texcoord0.xy);
	#endif

	#ifdef SUBTEXTURE
		vec2 uv2 = v_Texcoord0.zw + color.r * _SubTex_Perturbation;
		color *= texture2D(_SubTex, uv2);
	#endif

	#ifdef _ALPHATEST_ON
		if (color.a < _Cutoff)
			discard;
	#endif
	
	gl_FragColor = color;
	
	#ifdef FOG
		float lerpFact = clamp((1.0 / gl_FragCoord.w - u_FogStart) / u_FogRange, 0.0, 1.0);
		#ifdef ADDTIVEFOG
			gl_FragColor.rgb = mix(gl_FragColor.rgb, vec3(0.0), lerpFact);
		#else
			gl_FragColor.rgb = mix(gl_FragColor.rgb, u_FogColor, lerpFact);
		#endif
	#endif
}

