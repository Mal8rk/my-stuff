#version 120
uniform sampler2D iChannel0;

uniform float time;

uniform vec2 imageSize;

#include "shaders/logic.glsl"

void main()
{
	vec2 originalXY = gl_TexCoord[0].xy;

	vec2 xy = originalXY;

	xy.y += 1.0;
	xy.y -= (time*0.01) * xy.y;

	vec4 c = texture2D(iChannel0, xy);

	//c = vec4(xy.y,0.0,0.0,1.0);

	c *= max(0.0,1.0 - time/96.0);
	c *= min(0.7, originalXY.y * 2.0);
	//c *= 0.5;
	
	gl_FragColor = c*gl_Color;
}