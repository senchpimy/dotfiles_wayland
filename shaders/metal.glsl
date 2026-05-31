/*
	Bumped Sinusoidal Warp
	----------------------
    Fixed for C++ Viewer (Textureless mode activated)
*/

// Macros to prevent errors with missing textures
#define texture(s, uv) vec4(0.0)
#define textureLod(s, uv, lod) vec4(0.0)

// Warp function. Variations have been around for years. 
vec2 W(vec2 p){
    
    p = (p + 3.)*4.;

    float t = iTime/2.;

    // Layered, sinusoidal feedback, with time component.
    for (int i=0; i<3; i++){
        p += cos(p.yx*3. + vec2(t, 1.57))/3.;
        p += sin(p.yx + t + vec2(1.57, 0))/2.;
        p *= 1.3;
    }

    // A bit of jitter to counter the high frequency sections.
    p += fract(sin(p+vec2(13, 7))*5e5)*.03 - .015;

    return mod(p, 2.) - 1.; // Range: [vec2(-1), vec2(1)]
}

// Bump mapping function. 
float bumpFunc(vec2 p){ 
	return length(W(p))*.7071; // Range: [0, 1]
}

// Helper for the procedural color pattern
vec3 smoothFract(vec3 x){ 
    x = fract(x); 
    return min(x, x*(1.-x)*12.); 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){

    // Screen coordinates.
	vec2 uv = (fragCoord - iResolution.xy*.5)/iResolution.y;
    
    // VECTOR SETUP
    vec3 sp = vec3(uv, 0); // Surface posion
    vec3 rd = normalize(vec3(uv, 1)); // Unit direction vector
    vec3 lp = vec3(cos(iTime)*.5, sin(iTime)*.2, -1); // Light position
	vec3 sn = vec3(0, 0, -1); // Plane normal
 
    // BUMP MAPPING
    vec2 eps = vec2(4./iResolution.y, 0);
    
    float f = bumpFunc(sp.xy); 
    float fx = bumpFunc(sp.xy - eps.xy); 
    float fy = bumpFunc(sp.xy - eps.yx); 
   
 	// Controls how much the bump is accentuated.
	const float bumpFactor = .05;
    
    // Using the above to determine the dx and dy function gradients.
    fx = (fx - f)/eps.x; // Change in X
    fy = (fy - f)/eps.x; // Change in Y.

    sn = normalize(sn + vec3(fx, fy, 0)*bumpFactor);   
    
    // LIGHTING
	vec3 ld = lp - sp;
	float lDist = max(length(ld), .0001);
	ld /= lDist;

    // Light attenuation.    
    float atten = 1./(1. + lDist*lDist*.15);
    
    // Using the bump function, "f," to darken the crevices.
    atten *= f*.9 + .1; 

	// Diffuse value.
	float diff = max(dot(sn, ld), 0.);  
    // Enhancing the diffuse value a bit.
    diff = pow(diff, 4.)*.66 + pow(diff, 8.)*.34; 
    // Specular highlighting.
    float spec = pow(max(dot( reflect(-ld, sn), -rd), 0.), 12.); 
    
	
    // TEXTURE COLOR -> SWITCHED TO PROCEDURAL
    // Original code used texture(iChannel0...), which we don't have.
    // We use the "Textureless" version provided by the author:
    
    vec3 texCol = smoothFract( W(sp.xy).xyy )*.1 + .2;
    
    // Make it a bit more colorful than the default gray
    texCol *= vec3(0.8, 0.9, 1.0) + 0.5*cos(iTime*0.5 + vec3(0,2,4)); 
    
    // FINAL COLOR
    vec3 col = (texCol*(diff*vec3(1, .97, .92)*2. + .5) + vec3(1, .6, .2)*spec*2.)*atten;
    
    // Faux environment mapping
    float ref = max(dot(reflect(rd, sn), vec3(1)), 0.);
    col += col*pow(ref, 4.)*vec3(.25, .5, 1)*3.;
    
    // Gamma correction
	fragColor = vec4(sqrt(clamp(col, 0., 1.)), 1);
}
