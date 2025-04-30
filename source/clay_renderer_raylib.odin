package game

import clay "/clay-odin"
import "core:math"
import "core:strings"
import "vendor:raylib"
import "base:runtime"
import "core:fmt"

RaylibFont :: struct {
    fontId: u16,
    font:   raylib.Font,
}

clayColorToRaylibColor :: proc(color: clay.Color) -> raylib.Color {
    return raylib.Color{cast(u8)color.r, cast(u8)color.g, cast(u8)color.b, cast(u8)color.a}
}


raylibFonts := [10]RaylibFont{}

measureText :: proc "c" (text: clay.StringSlice, config: ^clay.TextElementConfig, userData: rawptr) -> clay.Dimensions {
    // Measure string size for Font
    context = runtime.default_context()
    textSize: clay.Dimensions = {0, 0}

    maxTextWidth: f32 = 0
    lineTextWidth: f32 = 0

    textHeight := cast(f32)config.fontSize
    fontToUse := raylibFonts[config.fontId].font

    for i in 0 ..< int(text.length) {
        if (text.chars[i] == '\n') {
            maxTextWidth = max(maxTextWidth, lineTextWidth)
            lineTextWidth = 0
            continue
        }
        index := cast(i32)text.chars[i] - 32
        if (fontToUse.glyphs[index].advanceX != 0) {
            lineTextWidth += cast(f32)fontToUse.glyphs[index].advanceX
        } else {
            lineTextWidth += (fontToUse.recs[index].width + cast(f32)fontToUse.glyphs[index].offsetX)
        }
    }
    text_ := string(text.baseChars[:text.length])
    cloned := strings.clone_to_cstring(text_, context.temp_allocator)
    lineTextWidth = raylib.MeasureTextEx(fontToUse,cloned,auto_cast config.fontSize,auto_cast config.letterSpacing).x +raylib.MeasureTextEx(fontToUse,".",auto_cast config.fontSize,auto_cast config.letterSpacing).x
    maxTextWidth = max(maxTextWidth, lineTextWidth)
    textSize.width = maxTextWidth
    textSize.height = textHeight

    return textSize
}

clayRaylibRender :: proc(renderCommands: ^clay.ClayArray(clay.RenderCommand), allocator := context.temp_allocator) {
    for i in 0 ..< int(renderCommands.length) {
        renderCommand := clay.RenderCommandArray_Get(renderCommands, cast(i32)i)
        boundingBox := renderCommand.boundingBox
        switch (renderCommand.commandType) {
        case clay.RenderCommandType.None:
            {}
        case clay.RenderCommandType.Text:
            config := renderCommand.renderData.text
            // Raylib uses standard C strings so isn't compatible with cheap slices, we need to clone the string to append null terminator
            text := string(config.stringContents.chars[:config.stringContents.length])
            cloned := strings.clone_to_cstring(text, allocator)
            fontToUse: raylib.Font = raylibFonts[config.fontId].font
            raylib.DrawTextEx(
                fontToUse,
                cloned,
                raylib.Vector2{boundingBox.x, boundingBox.y},
                cast(f32)config.fontSize,
                cast(f32)config.letterSpacing,
                clayColorToRaylibColor(config.textColor),
            )
        case clay.RenderCommandType.Image:
            config := renderCommand.renderData.image
            tintColor := config.backgroundColor
            if (tintColor.rgba == 0) {
                tintColor = { 255, 255, 255, 255 }
            }
            // TODO image handling
            imageTexture := cast(^Atlas_Texture)config.imageData
            // draw_by_id_2d(imageTexture^,{boundingBox.x, boundingBox.y,boundingBox.width ,boundingBox.height},{0,0},0,clayColorToRaylibColor(tintColor))

            
            dest:Rect={boundingBox.x, boundingBox.y,boundingBox.width,boundingBox.width }
            origin:raylib.Vector2={0,0}
            rot:f32=0
            tint:raylib.Color=clayColorToRaylibColor(tintColor)
            atlas:raylib.Texture2D=g.as.atlas
            raylib.DrawTexturePro(atlas, imageTexture.rect, dest, origin, rot, tint)
            // raylib.DrawTextureEx(imageTexture^, raylib.Vector2{boundingBox.x, boundingBox.y}, 0, boundingBox.width / cast(f32)imageTexture.width, clayColorToRaylibColor(tintColor))
        case clay.RenderCommandType.ScissorStart:
            raylib.BeginScissorMode(
                cast(i32)math.round(boundingBox.x),
                cast(i32)math.round(boundingBox.y),
                cast(i32)math.round(boundingBox.width),
                cast(i32)math.round(boundingBox.height),
            )
        case clay.RenderCommandType.ScissorEnd:
            raylib.EndScissorMode()
        case clay.RenderCommandType.Rectangle:
            config := renderCommand.renderData.rectangle
            if (config.cornerRadius.topLeft > 0) {
                radius: f32 = (config.cornerRadius.topLeft * 2) / min(boundingBox.width, boundingBox.height)
                raylib.DrawRectangleRounded(raylib.Rectangle{boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height}, radius, 8, clayColorToRaylibColor(config.backgroundColor))
            } else {
                raylib.DrawRectangle(cast(i32)boundingBox.x, cast(i32)boundingBox.y, cast(i32)boundingBox.width, cast(i32)boundingBox.height, clayColorToRaylibColor(config.backgroundColor))
            }
        case clay.RenderCommandType.Border:
            config := renderCommand.renderData.border
            // Left border
            if (config.width.left > 0) {
                raylib.DrawRectangle(
                    cast(i32)math.round(boundingBox.x),
                    cast(i32)math.round(boundingBox.y + config.cornerRadius.topLeft),
                    cast(i32)config.width.left,
                    cast(i32)math.round(boundingBox.height - config.cornerRadius.topLeft - config.cornerRadius.bottomLeft),
                    clayColorToRaylibColor(config.color),
                )
            }
            // Right border
            if (config.width.right > 0) {
                raylib.DrawRectangle(
                    cast(i32)math.round(boundingBox.x + boundingBox.width - cast(f32)config.width.right),
                    cast(i32)math.round(boundingBox.y + config.cornerRadius.topRight),
                    cast(i32)config.width.right,
                    cast(i32)math.round(boundingBox.height - config.cornerRadius.topRight - config.cornerRadius.bottomRight),
                    clayColorToRaylibColor(config.color),
                )
            }
            // Top border
            if (config.width.top > 0) {
                raylib.DrawRectangle(
                    cast(i32)math.round(boundingBox.x + config.cornerRadius.topLeft),
                    cast(i32)math.round(boundingBox.y),
                    cast(i32)math.round(boundingBox.width - config.cornerRadius.topLeft - config.cornerRadius.topRight),
                    cast(i32)config.width.top,
                    clayColorToRaylibColor(config.color),
                )
            }
            // Bottom border
            if (config.width.bottom > 0) {
                raylib.DrawRectangle(
                    cast(i32)math.round(boundingBox.x + config.cornerRadius.bottomLeft),
                    cast(i32)math.round(boundingBox.y + boundingBox.height - cast(f32)config.width.bottom),
                    cast(i32)math.round(boundingBox.width - config.cornerRadius.bottomLeft - config.cornerRadius.bottomRight),
                    cast(i32)config.width.bottom,
                    clayColorToRaylibColor(config.color),
                )
            }
            if (config.cornerRadius.topLeft > 0) {
                raylib.DrawRing(
                    raylib.Vector2{math.round(boundingBox.x + config.cornerRadius.topLeft), math.round(boundingBox.y + config.cornerRadius.topLeft)},
                    math.round(config.cornerRadius.topLeft - cast(f32)config.width.top),
                    config.cornerRadius.topLeft,
                    180,
                    270,
                    10,
                    clayColorToRaylibColor(config.color),
                )
            }
            if (config.cornerRadius.topRight > 0) {
                raylib.DrawRing(
                    raylib.Vector2{math.round(boundingBox.x + boundingBox.width - config.cornerRadius.topRight), math.round(boundingBox.y + config.cornerRadius.topRight)},
                    math.round(config.cornerRadius.topRight - cast(f32)config.width.top),
                    config.cornerRadius.topRight,
                    270,
                    360,
                    10,
                    clayColorToRaylibColor(config.color),
                )
            }
            if (config.cornerRadius.bottomLeft > 0) {
                raylib.DrawRing(
                    raylib.Vector2{math.round(boundingBox.x + config.cornerRadius.bottomLeft), math.round(boundingBox.y + boundingBox.height - config.cornerRadius.bottomLeft)},
                    math.round(config.cornerRadius.bottomLeft - cast(f32)config.width.top),
                    config.cornerRadius.bottomLeft,
                    90,
                    180,
                    10,
                    clayColorToRaylibColor(config.color),
                )
            }
            if (config.cornerRadius.bottomRight > 0) {
                raylib.DrawRing(
                    raylib.Vector2 {
                        math.round(boundingBox.x + boundingBox.width - config.cornerRadius.bottomRight),
                        math.round(boundingBox.y + boundingBox.height - config.cornerRadius.bottomRight),
                    },
                    math.round(config.cornerRadius.bottomRight - cast(f32)config.width.bottom),
                    config.cornerRadius.bottomRight,
                    0.1,
                    90,
                    10,
                    clayColorToRaylibColor(config.color),
                )
            }
        case clay.RenderCommandType.Custom:
            custom := cast(^entity_index) renderCommand.renderData.custom.customData
            ent :=get_entity_by_index(custom^)
            if ent!=nil{
                render_ent_block_pos_overide(ent,{boundingBox.x-(cast(f32)block_size/2),boundingBox.y-(cast(f32)block_size/2)})
            }
            
            
        // Implement custom element rendering here
        }
    }
}
