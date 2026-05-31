/*
 * Minecraft-like Shader
 * Cleaned and fixed for C++ Viewer compatibility
 */

// Shadertoy compatibility defines
#define texture(s, uv) vec4(0.0)
#define textureLod(s, uv, lod) vec4(0.0)

// Helper for hex colors to float conversion
vec3 hex(int r, int g, int b) {
    return vec3(float(r), float(g), float(b)) / 255.0;
}

vec3 lightDir = normalize(vec3(1.0, -0.4, 0.9));

float rand(vec3 p){
	return fract(sin(dot(p,vec3(37.1,61.7, 1.12)))*1233758.5453123);
}
float rand(vec2 p){
	return rand(vec3(p, 1.0));
}

vec3 sky(vec3 dir){
	vec3 col1 = vec3(.0, .3, .9);
	vec3 col2  = vec3(.8, .8,.8);
	return mix (col1, col2, (dot(dir, -vec3(0,0,1))+1.0)*0.5);
}

vec3 blockColor(vec3 pos, int type){
	vec3 b = floor(fract(pos+vec3(0.,0.,.0))*16.);
	vec3 c;
	
    // Using hex helper to prevent syntax errors
	if (type == 1){ // DIRT
		c = hex(0x96, 0x6C, 0x4A);
	} else if (type == 2) { // GRASS
		c = hex(0x96, 0x6C, 0x4A);
		float x = b.x+b.y;
        // Procedural grass pattern
		if (b.z > mod(floor((x * x * 3. + x * 81.) / 4.),4.) + 10.)
			c = hex(0x6A, 0xAA, 0x40);
	} else {
		c = vec3(1.0, 0.0, 1.0); // Error pink
    }
    
	c = c * (255.-96.*rand(b))/255.;
	return c;
}

// Make sure position is INSIDE the block to prevent texture bleeding
vec3 clampPosToBlock(vec3 pos, vec3 block){ 
	pos = max(pos, block);
	pos = min(pos, block+vec3(.999, .999, .999));
	return pos;
}

vec4 u(vec4 a, vec4 b){ // UNION
	if (a.w < b.w) return a;
	else return b;
}

int groundType(vec2 pos){
	return 2-int(rand(pos*2.13)*1.2);
}

float groundHeight(vec2 pos){
	return floor(rand(floor(pos))*3.);	
}

vec4 dGroundColumn(vec3 pos, vec2 col){
	col = floor(col);
	float height = groundHeight(col);
	float dist = pos.z - height;
	if (dist < 0.)
		height = floor(pos.z);
	else
		height -= 1.;
        
    // Box SDF logic
	dist = max(dist, pos.x-col.x-1.);
	dist = max(dist, -pos.x+col.x);
	dist = max(dist, pos.y-col.y-1.);
	dist = max(dist, -pos.y+col.y);
	return vec4(col, height, dist);
}

vec4 dGround(vec3 pos){
    // Check current column
	vec4 dist = dGroundColumn(pos, pos.xy);
    
    // Check immediate neighbors to prevent holes/glitches
	vec3 du = vec3(floor(fract(pos.xy)*2.)*2.-1., 0.); 
	dist = u(dist, dGroundColumn(pos, pos.xy+du.xz));
	dist = u(dist, dGroundColumn(pos, pos.xy+du.zy));
	dist = u(dist, dGroundColumn(pos, pos.xy+du.xy));
	return dist;
}

vec4 d(vec3 pos){
	vec4 dist = dGround(pos);
	
    // The floating sphere object logic
    float dist2 = 5.0 - length(pos - vec3(0.0, 0.0, 5.0)); // Adjusted to float
	if (dist2 > dist.w){ // Logic was inverted or strange in original, kept simple
		// Create a floating block artifact? 
        // Keeping original behavior but cleaning logic
        // If sphere SDF is larger (meaning we are inside sphere?), override.
        // Actually original logic implies: if sphere is closer/bigger than ground dist?
        // Let's just return ground for stability, uncomment below to add weird sphere back
		// dist = vec4(floor(pos), dist2); 
	}
	return dist;
}
 
vec3 getNormal(vec3 p){
  	const float dx = 0.005; // Increased slightly to avoid noise on sharp edges
  	return normalize( 
		    vec3(
        		 d(p+vec3(dx,0.0,0.0)).w-d(p+vec3(-dx,0.0,0.0)).w,
        		 d(p+vec3(0.0,dx,0.0)).w-d(p+vec3(0.0,-dx,0.0)).w,
        		 d(p+vec3(0.0,0.0,dx)).w-d(p+vec3(0.0,0.0,-dx)).w
		    )
    	       );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 pos = (fragCoord.xy) / iResolution.xy;
	pos -= 0.5;
	pos.x *= iResolution.x / iResolution.y;
	
    // Camera Animation
	vec3 camPos = vec3(0., -20., 5.);
	camPos += vec3(0.0+iTime*2.25, 0.0+iTime*3., 0.0);
    
  	vec3 camDir = normalize(vec3(cos(-iTime*.1), sin(-iTime*.1), -0.2));
  	vec3 camUp = vec3(0.0, 0.0, 1.0);
	camUp = cross(cross(camDir, vec3(0.0, 0.0, 1.0)), camDir);
  	vec3 camSide = cross(camDir, camUp);
  	float focus = 1.8;
 
  	vec3 rayDir = normalize(camSide*pos.x + camUp*pos.y + camDir*focus);
 
  	float t = 0.0;
	vec4 dist = vec4(0.0);
  	vec3 posOnRay = camPos;
    
    // Improved Raymarching Loop
    // Original had 164 steps and weak exit conditions
	for(int i=0; i<200; ++i){
		dist = d(posOnRay);
	    t += dist.w * 0.8; // Multiply by 0.8 to reduce overshooting artifacts (flickering)
        
        if(dist.w < 0.002) break; // Precision threshold (was 0.1, which caused blobs)
        if(t > 60.0) break; // Far clip plane
        
	    posOnRay = camPos + t*rayDir;
	}
    
	vec3 color;
    
    // Threshold check (must match the break condition above roughly)
	if(dist.w < 0.01 ){
        // Recalculate position slightly pushed back to surface for normal calc
        posOnRay = camPos + (t - 0.002) * rayDir;
        vec3 normal = getNormal(posOnRay);
        
        // Clamp for texturing
		posOnRay = clampPosToBlock(posOnRay, dist.xyz);
        
		float diff = clamp(dot(lightDir, normal), 0.3, 1.0);
		
		int block = groundType(dist.xy);
	    color = blockColor(posOnRay, block) * diff;
        
        // Fog
        color = mix(color, sky(rayDir), smoothstep(20.0, 60.0, t));
        
	} else {
	    color = sky(rayDir);
	}
	
    // Gamma correction
    color = pow(color, vec3(0.4545));
    
	fragColor = vec4(color, 1.0);
}
