Documentation Author: Niko Procopi 2019

This tutorial was designed for Visual Studio 2017 / 2019
If the solution does not compile, retarget the solution
to a different version of the Windows SDK. If you do not
have any version of the Windows SDK, it can be installed
from the Visual Studio Installer Tool

Welcome to the Cubemap Reflection-Specular Tutorial!
Prerequesites: Specular Mapping, Reflections-Bumpy

Remember how the Reflections-Bumpy tutorial was a combination of
Reflections-Flat, and normal mapping? This tutorial will be a combination
of Reflections-Bumpy and Specular Lighting. 

We changed the material from rock to ice, because we thought it looked nice.
Feel free to change it back to rock if you want.

Step 1: Combine two tutorials
Setup your fragment shader to calculate the pixel color from 
Reflections-Bumpy, and the pixel color from Specular Lighting.
Meaning: Eventually, you should have two lines of code
	vec4 worldColor = (color * finalDiffuseColor) + finalSpecularColor;
	vec4 skyColor = texture(cubeMap, outVec);
	
Step 2: Reflectivity:
For this tutorial, our reflectivity will come from the specular map:
	float reflectivity = texture(specularMap, uv).r;
That means, the brighter the pixel on the specular map, more of the 
skybox will be visible at this pixel. The darker the spec map pixel,
the more of the original object we will see at this pixel
	
Step 3: Mix them together
Then, we literally "mix" the colors together. GLSL has a function
called "mix" for this very purpose
	gl_FragColor = mix(worldColor, skyColor, reflectivity);

But what does "mix" actually do?
The less-efficient equivalent to the line above would be:
	gl_FragColor = worldColor * 1-reflectivity + skyColor * reflectivity
But why do we need that? How does that work?
Lets pretend reflectivity is 1.0, that means the pixel is 100% skybox
and 0% the original object's color, that would be
	worldColor * 0 + skyColor * 1
Lets pretend reflectivity is 0.0, that means the pixel is 0% skybox
and 100% the original object's color, that would be
	worldColor * 1 + skyColor * 0

This is where reflection comes down to preference.
If you want your reflections to look insanely awesome, but not realistic, stop here.
If you want your reflections to look realistic (but not as awesome), proceed to Step 4.
If you are using the rock material from the last tutorial, you might want to stop here.

Step 4: Correction
If we use this line, there will be some problems with accuracy
	gl_FragColor = mix(worldColor, skyColor, reflectivity);
The problem with this, is that any color of the skybox can mix with any color of the object's texture.
At first this doesn't sound like a problem, but think about the lighting equation we've been using:
	vec4 worldColor = (color * finalDiffuseColor) + finalSpecularColor;
The reason we multiply color by DiffuseColor is so that a perfectly red object only reflects red light.
If we have a perfectly blue object ( RGB = {0, 0, 1} ), and a perfectly green skybox (RGB = {0, 1, 0} ),
then there should be no reflection. To fix this, we simply swap the old equation with this new equation:
	gl_FragColor = mix(worldColor, skyColor*worldColor, reflectivity);

How to Improve:	
Combine this tutorial with Shadow mapping
  Go to the RenderToTexture tutorial
  Then look at the Shadow Mapping tutorial (coming soon)
