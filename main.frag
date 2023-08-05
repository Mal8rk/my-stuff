#version 120
uniform sampler2D iChannel0;

uniform sampler2D noiseTexture;
uniform vec2 noiseSize;

uniform float teleportFade;

uniform vec2 imageSize;
uniform vec2 frames;

#include "shaders/logic.glsl"

void main()
{
	vec2 xy = gl_TexCoord[0].xy;

	float noise = texture2D(noiseTexture, mod(xy * imageSize, imageSize / frames) / noiseSize).r;

	vec4 c = texture2D(iChannel0, xy);

	//c = vec4(noise,noise,noise,1.0);

	c *= le(teleportFade,noise);
	
	gl_FragColor = c*gl_Color;
}