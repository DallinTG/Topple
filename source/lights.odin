package game

import rl "vendor:raylib"

max_lights::4
// Light data
light:: struct {   
    type:i32,
    enabled:bool,
    position:[3]f32,
    target:[3]f32,
    color:rl.Color,
    attenuation:f32,
    
    // Shader locations
    enabledLoc:i32,
    typeLoc:i32,
    positionLoc:i32,
    targetLoc:i32,
    colorLoc:i32,
    attenuationLoc:i32,
}

// Light type
light_type ::enum {
    LIGHT_DIRECTIONAL,
    LIGHT_POINT,
}






/***********************************************************************************
*
*   RLIGHTS IMPLEMENTATION
*
************************************************************************************/


lightsCount:i32 = 0    // Current amount of created lights

// Create a light and get shader locations
CreateLight::proc(type:i32, position:[3]f32, target:[3]f32, color:rl.Color, shader:rl.Shader)->light{
    light:light
    if (lightsCount < max_lights){
        light.enabled = true
        light.type = type
        light.position = position
        light.target = target
        light.color = color

        // NOTE: Lighting shader naming must be the provided ones
        light.enabledLoc = rl.GetShaderLocation(shader, rl.TextFormat("lights[%i].enabled", lightsCount))
        light.typeLoc = rl.GetShaderLocation(shader, rl.TextFormat("lights[%i].type", lightsCount))
        light.positionLoc = rl.GetShaderLocation(shader, rl.TextFormat("lights[%i].position", lightsCount))
        light.targetLoc = rl.GetShaderLocation(shader, rl.TextFormat("lights[%i].target", lightsCount))
        light.colorLoc = rl.GetShaderLocation(shader, rl.TextFormat("lights[%i].color", lightsCount))

        UpdateLightValues(shader, light)
        
        lightsCount+=1
    }

    return light
}

// Send light properties to shader
// NOTE: Light shader locations should be available 
UpdateLightValues::proc(shader:rl.Shader,  light:light){
    light_type:i32=light.type
    light_enabled:=cast(i32)light.enabled
    // Send to shader light enabled state and type
    rl.SetShaderValue(shader, light.enabledLoc, &light_enabled, .INT)
    rl.SetShaderValue(shader, light.typeLoc, &light_type, .INT)

    // Send to shader light position values
    position:[3]f32 = { light.position.x, light.position.y, light.position.z }
    rl.SetShaderValue(shader, light.positionLoc, &position, .VEC3)

    // Send to shader light target position value
    target:[3]f32 = { light.target.x, light.target.y, light.target.z }
    rl.SetShaderValue(shader, light.targetLoc, &target, .VEC3)

    // Send to shader light color values
    color:[4]f32 = { 
        cast(f32)light.color.r/cast(f32)255, 
        cast(f32)light.color.g/cast(f32)255, 
        cast(f32)light.color.b/cast(f32)255, 
        cast(f32)light.color.a/cast(f32)255,
    }
    rl.SetShaderValue(shader, light.colorLoc, &color, .VEC4)
}

