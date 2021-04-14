#if defined(GL_FRAGMENT_PRECISION_HIGH)// 原来的写法会被我们自己的解析流程处理，而我们的解析是不认内置宏的，导致被删掉，所以改成 if defined 了
	precision highp float;
#else
	precision mediump float;
#endif

uniform sampler2D u_MainTexture;
uniform vec4 u_MainColor;

#ifdef SUBTEXTURE
	uniform sampler2D _SubTex;
	uniform float _SubTex_Perturbation;
#endif

#ifdef _SCROLL2TEXBLEND_ON
	varying vec4 v_Texcoord0;
#else
	varying vec2 v_Texcoord0;
#endif

varying vec4 v_Color;

void main()
{
	vec4 color = 2.0 * u_MainColor * v_Color;
	#ifdef MAINTEXTURE
		vec4 mainTextureColor = texture2D(u_MainTexture, v_Texcoord0.xy);
		color *= mainTextureColor;
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
}

     