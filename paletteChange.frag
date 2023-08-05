// Replaces colours, based on the paletteImage.

#version 120
uniform sampler2D iChannel0;

uniform sampler2D paletteImage;
uniform float currentPaletteY;
uniform float colourSimilarityThreshold;

uniform vec4 tintColor;

#define COLOUR_COUNT 1


#include "shaders/logic.glsl"


float coloursAreCloseEnough(vec4 a, vec4 b)
{
	// le(abs(a.r-b.r), colourSimilarityThreshold)
	// le(abs(a.g-b.g), colourSimilarityThreshold)
	// le(abs(a.b-b.b), colourSimilarityThreshold)
	// le(abs(a.a-b.a), colourSimilarityThreshold)
	//return and(and(and(le(abs(a.r-b.r), colourSimilarityThreshold), le(abs(a.g-b.g), colourSimilarityThreshold)), le(abs(a.b-b.b), colourSimilarityThreshold)), le(abs(a.a-b.a), colourSimilarityThreshold));

	return le(abs(a.r - b.r) + abs(a.g - b.g) + abs(a.b - b.b) + abs(a.a - b.a), colourSimilarityThreshold);
}


void main()
{
	vec4 original = texture2D(iChannel0, gl_TexCoord[0].xy);

	vec4 c = original;

	for (int i = 0; i < COLOUR_COUNT; i++) {
		vec4 colourHere      = texture2D(paletteImage, vec2((i+0.1) / COLOUR_COUNT, 0.0));
		vec4 replacementHere = texture2D(paletteImage, vec2((i+0.1) / COLOUR_COUNT, currentPaletteY));

		c = mix(c, replacementHere, coloursAreCloseEnough(original,colourHere));
	}

	// Apply tint
	c.rgb *= tintColor.rgb;
	c *= tintColor.a;
	
	gl_FragColor = c*gl_Color;
}