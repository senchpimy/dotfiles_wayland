/*
 * Weather Map Style - Procedural Version
 * Original style preserved.
 * Texture dependencies replaced with procedural noise generation.
 */

// Define styles from original
#define PAPER

#ifdef PAPER
#define  LOW_PRESSURE vec3(0.,0.5,1.)
#define HIGH_PRESSURE vec3(1.,0.5,0.)
#else
#define  LOW_PRESSURE vec3(1.,0.5,0.)
#define HIGH_PRESSURE vec3(0.,0.5,1.)
#endif

// --- PROCEDURAL NOISE FUNCTIONS TO REPLACE TEXTURES ---

// Random hash
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// 2D Noise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Fractal Brownian Motion for Land and Wind
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));
    for (int i = 0; i < 5; i++) {
        v += a * noise(p);
        p = rot * p * 2.0 + vec2(10.0);
        a *= 0.5;
    }
    return v;
}

// Emulate iChannel0 (Land Map)
float getLandMask(vec2 uv) {
    // Create random continents
    float n = fbm(uv * 4.0 + vec2(10.0));
    // Sharp transition for coastlines
    return smoothstep(0.48, 0.52, n); 
}

// Emulate iChannel1 (Wind Vectors and Pressure)
vec3 getWindAndPressure(vec2 uv) {
    // Curl noise to simulate wind swirling
    float t = iTime * 0.2;
    float n1 = fbm(uv * 3.0 + vec2(0.0, t));
    float n2 = fbm(uv * 3.0 + vec2(5.2, t));
    
    // Wind vector (derivative-ish)
    vec2 wind = vec2(n1 - 0.5, n2 - 0.5) * 2.0;
    
    // Pressure (fake based on wind)
    float pressure = 1012.0 + wind.x * 20.0;
    
    return vec3(pressure, wind.x, wind.y);
}

// Emulate iChannel2 (Flow Noise)
float getFlowNoise(vec2 coord) {
    return hash(coord);
}

// --- ORIGINAL LOGIC ADAPTED ---

// Constants missing in single file
#define MAPRES iResolution.xy
#define PASS3 vec2(0.0)
#define PASS4 vec2(0.0)

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    float lat = 180. * fragCoord.y/iResolution.y - 90.;

    // Coordinates setup
    vec2 p = fragCoord * MAPRES / iResolution.xy;
    if (p.x < 1.) p.x = 1.;
    vec2 uv = p / iResolution.xy;
    
    // 1. Get Land Mask (Procedural instead of texture iChannel0)
    float land = getLandMask(uv * vec2(2.0, 1.0)); // Scale for aspect ratio
    
    fragColor = vec4(0,0,0,1);
    
    // Land outline logic
    if (0.25 < land && land < 0.75) fragColor.rgb = vec3(0.5); // Edges (not perfect in proc, but okay)
    else if (land > 0.5) fragColor.rgb = vec3(0.5); // Fill land
    
    // 2. Get Weather Data (Procedural instead of texture iChannel1)
    vec3 weather = getWindAndPressure(uv * vec2(2.0, 1.0));
    float mbar = weather.x;
    vec2 v = weather.yz; // Wind vector
    
    // Mouse interaction disabled (default to false path) or simulated
    // We assume iMouse.z == 0 to show the wind view
    if (false) { // if (iMouse.z > 0.)
        vec3 r = LOW_PRESSURE;
        r = mix(r, vec3(0), smoothstep(1000., 1012., floor(mbar)));
        r = mix(r, HIGH_PRESSURE, smoothstep(1012., 1024., floor(mbar)));
        fragColor.rgb += 0.5 * r;
    } else {
        // 3. Flow Noise (Procedural instead of iChannel2)
        // We need static noise for the particle streams look
        float flow = getFlowNoise(fragCoord); 
        
        vec3 hue = vec3(1.,0.75,0.5);
#ifndef PAPER
        hue = .6 + .6 * cos(atan(v.y,v.x) + vec3(0,23,21));
#endif
        // Visualizing the flow magnitude
        float alpha = clamp(length(v)*2.0, 0., 1.) * flow; // Added multiplier to v for intensity
        fragColor.rgb = mix(fragColor.rgb, hue, alpha);
    }

#ifdef PAPER
    // The paper aesthetic post-processing
    fragColor.rgb = 0.9 - 0.8 * fragColor.rgb;
    
    // Grid lines
    if (mod(fragCoord.x, floor(iResolution.x/36.)) < 1. ||
        mod(fragCoord.y, floor(iResolution.y/18.)) < 1.)
        fragColor.rgb = mix(fragColor.rgb, vec3(0.,0.5,1.), 0.2);
#endif
}
