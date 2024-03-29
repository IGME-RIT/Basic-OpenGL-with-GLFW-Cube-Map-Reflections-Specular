/*
Title: Specular Maps
File Name: fragment.glsl
Copyright � 2016, 2019
Author: David Erbelding, Niko Procopi
Written under the supervision of David I. Schwartz, Ph.D., and
supported by a professional development seed grant from the B. Thomas
Golisano College of Computing & Information Sciences
(https://www.rit.edu/gccis) at the Rochester Institute of Technology.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


#version 400 core

in vec3 position;
in vec2 uv;
in mat3 tbn;

uniform sampler2D diffuseMap;
uniform sampler2D normalMap;
uniform sampler2D specularMap;
uniform samplerCube cubeMap;

// Camera position is required for specular lighting
uniform vec3 cameraPosition;
// This value dictates how shiny the surface of the object is
uniform int specularExponent;

void main(void)
{
	vec4 ambientLight = vec4(.1, .1, .2, 1);
	vec3 pointLightPosition = vec3(1000, 500, 100);
	vec4 pointLightColor = vec4(1, 1, 1, 1);
	vec3 pointLightAttenuation = vec3(1, 1, 0);
	float pointLightRange = 2000;

	// calculate normal from normal map
	vec3 texnorm = normalize(vec3(texture(normalMap, uv)) * 2.0 - 1.0);
	vec3 norm = tbn * texnorm;

	
	// Calculate diffuse lighting
	vec3 lightDir = pointLightPosition - position;
	float distance = length(lightDir) / pointLightRange;
	float attenuation = 1 / (distance * distance * pointLightAttenuation.x + distance * pointLightAttenuation.y + pointLightAttenuation.z);
	float diffuseLight = clamp(dot(normalize(lightDir), normalize(norm)), 0, 1);
	vec4 finalDiffuseColor = clamp(pointLightColor * (diffuseLight) + ambientLight, 0, 1);
	

	// Calculate specular lighting
	// The specular color is similar to the the regular texture.
	// It determines what colors are reflected by the surface.
	vec4 specularColor = texture(specularMap, uv);

	// While diffuse light is deflected from the surface in all directions, specular light
	// is light that reflects in a specific path. The shinier an object, (for example, a mirror)
	// the less scattered the reflection is.
	// Here we calculate the vector of our light ray reflected by our normal vector:
	vec3 reflectDir = normalize(reflect(-lightDir, norm));

	// We also need the direction of the surface to our camera:
	vec3 surfaceToEyeDir = normalize(vec3(cameraPosition) - position);

	// Taking the dot product of the two will give us a value between -1 and 1.
	// 1 is very close to a perfect reflection, and -1 is the complete opposite direction.
	float specularLight = dot(reflectDir, surfaceToEyeDir);

	// Next we raise that value to the power of our specular exponent (determines how shiny an object is)
	// The higher the number, the closer it will stay to 1 as it's multiplied, but lower numbers will become significantly smaller to not reflect.
	// We also have to clamp between -1 and 1 here, because -1 to an even power would give us a positive light value and that doesn't make any sense.
	// And finally it's multiplied by attenuation, the same way it is with diffuse lighting
	specularLight = pow(clamp(specularLight, 0.0, 1.0), specularExponent) * attenuation;

	// Lastly multiply the color from our specular map with the light color, and scale by the strength of the specular light, and we have our value!
	vec4 finalSpecularColor = specularColor * pointLightColor * specularLight;

	// finally, sample from the texuture and apply the light.
	vec4 color = texture(diffuseMap, uv);
	vec4 worldColor = (color * finalDiffuseColor) + finalSpecularColor;

	// This part should mostly make sense.
	// We get a vector from the surface to the camera position.
	vec3 surfaceToEye = cameraPosition - position;
	// Reflect that vector over the surface normal, giving us the direction light would be reflecting to our eye from
	vec3 outVec = reflect(surfaceToEye, norm);

	// get texture and reflectivity
	vec4 texColor = texture(diffuseMap, uv);
	float reflectivity = texture(specularMap, uv).r;

	// sky color
	vec4 skyColor = texture(cubeMap, outVec);

	// We use that direction vector to read from the cube map (like a backwards skybox)
	gl_FragColor = mix(worldColor, skyColor, reflectivity);
}