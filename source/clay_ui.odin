package game

import "core:fmt"
import "core:math/linalg"
import "core:math"
import rl "vendor:raylib"
import noise"core:math/noise"
import clay "/clay-odin"
import "base:runtime"

ui_render_command:clay.ClayArray(clay.RenderCommand)

// Define some colors.
font_color::clay.Color{10, 10, 10, 255}
COLOR_LIGHT :: clay.Color{224, 215, 210, 255}
c_red :: clay.Color{108, 103, 130, 155}
c_red_hov :: clay.Color{108, 103, 130, 255}
COLOR_ORANGE :: clay.Color{225, 138, 50, 255}
COLOR_BLACK :: clay.Color{0, 0, 0, 255}

ui_page::enum{
    start,
    mode_sulect,
    game,
    setings,
}

ui_state::struct{
    b_page:ui_page,
    last_e_hov:u32,
    last_f_e_hov:u32,
    ui_eate_click:bool,

}

custom_element_type::union{
    ^entity_index,
}



// Layout config is just a struct that can be declared statically, or inline
sidebar_item_layout := clay.LayoutConfig {
    sizing = {
        width = clay.SizingGrow({}),
        height = clay.SizingFixed(50)
    },
}

error_handler :: proc "c" (errorData: clay.ErrorData) {
    // Do something with the error data.
}
init_clay_ui::proc(){
    min_memory_size: u32 = clay.MinMemorySize()
    memory := make([^]u8, min_memory_size)
    arena: clay.Arena = clay.CreateArenaWithCapacityAndMemory(auto_cast min_memory_size, memory)
    clay.Initialize(arena, { width = 1080, height = 720 }, { handler = error_handler })
    // clay.SetMeasureTextFunction(measureText,nil)
    clay.SetMeasureTextFunction(measureText,nil)
    // loadFont(FONT_ID_TITLE_56, 56, "resources/Calistoga-Regular.ttf")
    raylibFonts[1].font = rl.GetFontDefault()
    raylibFonts[1].fontId = 1
}
update_clay_ui::proc(){
    g.ui_st.ui_eate_click = false
    mouse_pos:= rl.GetMousePosition()
    is_mouse_down:=rl.IsMouseButtonDown(.LEFT)
    clay.SetPointerState(
        clay.Vector2 { mouse_pos.x, mouse_pos.y },
        is_mouse_down,
    )
    clay.SetLayoutDimensions({auto_cast rl.GetScreenWidth(),auto_cast rl.GetScreenHeight()})
    g.ui_st.last_e_hov = 0
    ui_render_command = create_ui_layout()
    ui_hov_sound()
}


// Re-useable components are just normal procs.
sidebar_item_component :: proc(index: u32) {
    if clay.UI()({
        id = clay.ID("SidebarBlob", index),
        layout = sidebar_item_layout,
        backgroundColor = COLOR_ORANGE,
    }) {}
}

// An example function to create your layout tree
create_ui_layout :: proc() -> clay.ClayArray(clay.RenderCommand) {
    
    clay.BeginLayout()
    if clay.UI()({
        id = clay.ID("OuterContainer"),
        layout = {
            sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
            // padding = { 16, 16, 16, 16 },
            // childGap = 16,
        },
        backgroundColor = { 0, 0, 0, 0 },
    }){
        if clay.UI()({
            id = clay.ID("sidebar_left"),
            layout = {
                layoutDirection = .TopToBottom,
                sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
                padding = { 16, 16, 16, 16 },
                // childGap = 16,
            },
            backgroundColor = { 0, 0, 0, 0 },
        }) {
            ui_next_box()
            if clay.Hovered(){
                if g.ui_st.b_page == .game && !g.game_over{
                // ui_ex_pading_up_d()
                // ui_bt_rot_left()
                    clay.OnHover(hi_move_left,nil)
                    // if rl.IsMouseButtonPressed(.LEFT){
                    //     fmt.print(" left ",g.time.dt,"\n")
                    //     if dos_entity_exist(g.block){
                    //         block_speed:f32=.5
                    //         g.block_pos+={block_size*-block_speed,block_size*0}
                    //         play_sound(.woosh,.7*block_speed,1.2)
                    //         play_sound(.woosh,.7*block_speed,1.5-block_speed)
                    //     }
                    // }
                }
            }
        }

        if clay.UI()({
            id = clay.ID("sidebar_mid"),
            
            layout = {
                sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
                layoutDirection = .TopToBottom,
                childAlignment = { y = .Center ,x = .Center},
                padding = { 16, 16, 16, 16 },
                childGap = 16,
            },
            backgroundColor = { 0, 0, 0, 0 },
        }) {
            ui_start()
            ui_game_mode()
            ui_game_over()
            ui_setings()
            ui_mid_top()
            ui_mid_bot()
            // ui_ex_pading()
            // if clay.Hovered(){
                // if g.ui_st.b_page == .game && !g.game_over{
                    
                    // if rl.IsMouseButtonPressed(.LEFT){
                    //     fmt.print(" mid ",g.time.dt,"\n")
                        
                    // }
                // }
            // }
        }

        if clay.UI()({
            id = clay.ID("sidebar_right"),
            layout = {
                sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
                padding = { 16, 16, 16, 16 },
                // layoutDirection = .TopToBottom,
            },
            backgroundColor = { 0, 0, 0, 0 },
        }) {    
            ui_score()
            if g.ui_st.b_page == .game && !g.game_over{
                if clay.Hovered(){
                    clay.OnHover(hi_move_right,nil)
                }
            }
        }
    }


    // Returns a list of render commands
    render_commands: clay.ClayArray(clay.RenderCommand) = clay.EndLayout()
    return render_commands
}

hi_move_left::proc"c"( elementId:clay.ElementId,  pointerInfo:clay.PointerData,  userData:rawptr){
    context=runtime.default_context()
    if pointerInfo.state == .PressedThisFrame{//&&!g.ui_st.ui_eate_click {
        fmt.print(" left ",g.time.dt,"\n")
        if dos_entity_exist(g.block){
            block_speed:f32=.5
            g.block_pos+={block_size*-block_speed,block_size*0}
            play_sound(.woosh,.7*block_speed,1.2)
            play_sound(.woosh,.7*block_speed,1.5-block_speed)
        }
    }
}
hi_move_right::proc"c"( elementId:clay.ElementId,  pointerInfo:clay.PointerData,  userData:rawptr){
    context=runtime.default_context()
    if pointerInfo.state == .PressedThisFrame{//&&!g.ui_st.ui_eate_click {
        fmt.print(" right ",g.time.dt, "\n")
        if dos_entity_exist(g.block){
            block_speed:f32=.5
            g.block_pos+={block_size*block_speed,block_size*0}
            play_sound(.woosh,.7*block_speed,1)
            play_sound(.woosh,.7*block_speed,1.5-block_speed)
        }
    }
}

ui_mid_top::proc(){
    if g.ui_st.b_page == .game && !g.game_over{
        if clay.UI()({
            layout = {
            sizing = { width = clay.SizingGrow({}),height = clay.SizingGrow({}) },
        }
        }){
            if clay.Hovered(){
                if rl.IsMouseButtonPressed(.LEFT){
                    g.block_rot+=90
                    if dos_entity_exist(g.block){
        
                        play_sound(.woosh,1,.7)
                    }
                }
            }
        }
    }
}

ui_mid_bot::proc(){
    if g.ui_st.b_page == .game && !g.game_over{
        if clay.UI()({
            layout = {
            sizing = { width = clay.SizingGrow({}),height = clay.SizingGrow({}) },
        }
        }){
            if clay.Hovered(){
                if rl.IsMouseButtonDown(.LEFT){
                    g.block_drop_speed_m = 4
                }
            }
        }
    }
}
// hi_rot_left::proc"c"( elementId:clay.ElementId,  pointerInfo:clay.PointerData,  userData:rawptr){
//     context=runtime.default_context()
//     if pointerInfo.state == .PressedThisFrame{//&& !g.ui_st.ui_eate_click {
//         g.block_rot-=90
//         if dos_entity_exist(g.block){
//             play_sound(.woosh,1,1.2)
//             block_speed:f32=.5
//             g.block_pos+={block_size*block_speed,block_size*0}
//             // play_sound(.woosh,.7*block_speed,1.2)
//             // play_sound(.woosh,.7*block_speed,1.5-block_speed)
            
//         }
//     }
// }
// ui_bt_rot_left::proc(){

//     if clay.UI()({
//     id = clay.ID("rot_left_box"),
//     layout = {
//         sizing = { width = clay.SizingFit({}), height = clay.SizingFit({})},
//         // padding= {32,32,32,32}
//     },
//     backgroundColor=c_red,
//     // image={
//     //     // imageData=cast(rawptr) &atlas_textures[.Rot_Left],
//     //     sourceDimensions= {},
//     // },
//     }){
//         if clay.Hovered(){
//             // fmt.print("waffles are the best,\n")
//             clay.OnHover(hi_rot_left,nil)
//         }
//         if clay.UI()({
//             id = clay.ID("rot_left_box"),
//             layout = {
//                 sizing = { width = clay.SizingFit({}), height = clay.SizingFit({})},
//                 padding= {32,32,32,32}
//             },
//             image={
//                 imageData=cast(rawptr) &atlas_textures[.Rot_Left],
//                 sourceDimensions= {},
//             },
//         }){

//         }
//     }
// }

ui_ex_pading::proc(){
    if clay.UI()({
        layout = {
        sizing = { width = clay.SizingGrow({}) },
    }
    }){}
}
ui_ex_pading_up_d::proc(){
    if clay.UI()({
        layout = {
        sizing = { width = clay.SizingGrow({}),height = clay.SizingGrow({}) },
    }
    }){}
}

ui_score::proc(){
    if g.ui_st.b_page == .game{
        ui_ex_pading()
        if clay.UI()({
            id = clay.ID("score_box"),
            layout = {
                sizing = { width = clay.SizingFit({}) },
                padding = { 16, 16, 16, 16 },
                childGap = 16,
                childAlignment = { y = .Center ,x = .Center},
            },
            backgroundColor = clay.Hovered()?c_red_hov:c_red,
            cornerRadius = { 6, 6, 6, 6 },
        }) {      
                      
            text :=fmt.tprint("Score ",g.score)
            clay.TextDynamic(
                text,
                clay.TextConfig({ textColor = font_color, fontSize = 20 ,textAlignment = .Right,letterSpacing=3,fontId = 1}),

            )

        }
    }
}

ui_next_box::proc(){
    if g.ui_st.b_page == .game && g.game_over != true{
        ui_ex_pading()
        if clay.UI()({
            id = clay.ID("next_box_box"),
            layout = {
                sizing = { width = clay.SizingFit({}),height = clay.SizingFit({}) },
                padding = { 16, 16, 16, 16 },
                childGap = 8,
                childAlignment = { y = .Top ,x = .Center},
                layoutDirection=.TopToBottom,
            },
            backgroundColor = clay.Hovered()?c_red_hov:c_red,
            cornerRadius = { 6, 6, 6, 6 },
        }) {      
            text :=fmt.tprint("Next Block")
            clay.TextDynamic(
                text,
                clay.TextConfig({ textColor = font_color, fontSize = 15 ,textAlignment = .Right,letterSpacing=3,fontId = 1}),
            )
            if dos_entity_exist( g.next_block){
                ent:=get_entity_by_index(g.next_block)
                if clay.UI()({
                    id = clay.ID("next_ent_box"),
                    layout = {
                        sizing = { width =clay.SizingFit({}) },
                        padding = { block_size*cast(u16)ent.w_h.x/2+(block_size), block_size*cast(u16)ent.w_h.x/2+(block_size), block_size*cast(u16)ent.w_h.y/2+(block_size), block_size*cast(u16)ent.w_h.y/2 +(block_size)},
                        childGap = 16,
                        childAlignment = { y = .Center ,x = .Center},
                    },
                    backgroundColor= {200,200,200,255},
                    cornerRadius = { 6, 6, 6, 6 },
            }){
                if dos_entity_exist( g.next_block){
                    ent:=get_entity_by_index(g.next_block)
                    if clay.UI()({
                        id = clay.ID("next_ent"),
                        layout = {
                            // sizing = { width =clay.SizingGrow({}) },
                            // padding = { block_size*cast(u16)ent.w_h.y/2, block_size*cast(u16)ent.w_h.x/2, block_size*cast(u16)ent.w_h.y/2, block_size*cast(u16)ent.w_h.x/2 },
                            // childGap = 16,
                            childAlignment = { y = .Center ,x = .Center},
                        },
                        backgroundColor= {255,255,255,255},
                        custom={&g.next_block},

                    }){
                    
                    }
                }
            }
            score:i32
            if ent != nil{
                score = ent.score
            }
            text_2 :=fmt.tprint("Value ",score)
            clay.TextDynamic(
                text_2,
                clay.TextConfig({ textColor = font_color, fontSize = 15 ,textAlignment = .Right,letterSpacing=3,fontId = 1}),
            )

            }
        }
    }
}

ui_start::proc(){
    if g.ui_st.b_page ==.start{
        ui_ex_pading()
        if clay.UI()({
            id = clay.ID("play"),
            layout = {
                sizing = { width = clay.SizingGrow({}) },
                padding = { 16, 16, 16, 16 },
                childGap = 16,
                childAlignment = { y = .Center ,x = .Center},
                
            },
            backgroundColor = clay.Hovered()?c_red_hov:c_red,
            cornerRadius = { 6, 6, 6, 6 },
        }){ 
            if clay.Hovered(){
            g.ui_st.last_e_hov = 405
                if rl.IsMouseButtonPressed(.LEFT){
                    g.ui_st.b_page = .mode_sulect
                    play_sound(.s_click,4,.75)
                }
            }

            text :=fmt.tprint("PLAY")
            clay.TextDynamic(
                text,
                clay.TextConfig({ textColor = font_color, fontSize = 20 ,textAlignment = .Right,letterSpacing=3,fontId = 1}),

            )
        }
        if clay.UI()({
            id = clay.ID("exit_to_desktop"),
            layout = {
                sizing = { width = clay.SizingGrow({}) },
                padding = { 16, 16, 16, 16 },
                childGap = 16,
                childAlignment = { y = .Center ,x = .Center},
            },
            backgroundColor = clay.Hovered()?c_red_hov:c_red,
            cornerRadius = { 6, 6, 6, 6 },
        }){
            if clay.Hovered(){
                g.ui_st.last_e_hov = 402
                if  rl.IsMouseButtonPressed(.LEFT){
                    play_sound(.s_click,4,.75)
                    rl.CloseWindow()
                }
            }
            text :=fmt.tprint("Exit To Desktop ")
            clay.TextDynamic(
                text,
                clay.TextConfig({ textColor = font_color, fontSize = 20 ,textAlignment = .Right,letterSpacing=3,fontId = 1}),

            )
        }
        ui_ex_pading()
    }
}

ui_game_mode::proc(){
    if g.ui_st.b_page ==.mode_sulect{
        ui_ex_pading()
        if clay.UI()({
            id = clay.ID("endless"),
            layout = {
                sizing = { width =clay.SizingGrow({}) },
                padding = { 16, 16, 16, 16 },
                childGap = 16,
                childAlignment = { y = .Center ,x = .Center},
                
            },
            backgroundColor = clay.Hovered()?c_red_hov:c_red,
            cornerRadius = { 6, 6, 6, 6 },
            
        }){
            if clay.Hovered(){
            g.ui_st.last_e_hov = 402
                if  rl.IsMouseButtonPressed(.LEFT){
                    g.ui_st.b_page = .game
                    g.mode = .endless
                    play_sound(.s_click,4,.75)
                    restart_game()
                }
            }
            text :=fmt.tprint("Endless")
            clay.TextDynamic(
                text,
                clay.TextConfig({ textColor = font_color, fontSize = 20 ,textAlignment = .Right,letterSpacing=3,fontId = 1}),

            )
        }
        if clay.UI()({
            id = clay.ID("puzzle"),
            layout = {
                sizing = { width = clay.SizingGrow({}) },
                padding = { 16, 16, 16, 16 },
                childGap = 16,
                childAlignment = { y = .Center ,x = .Center},
            },
            backgroundColor = clay.Hovered()?c_red_hov:c_red,
            cornerRadius = { 6, 6, 6, 6 },
        }){
            if clay.Hovered(){
                g.ui_st.last_e_hov = 401
                if rl.IsMouseButtonPressed(.LEFT){
                    g.ui_st.b_page = .game
                    g.mode = .puzzle
                    play_sound(.s_click,4,.75)
                    restart_game()
                }
            }
            text :=fmt.tprint("Puzzle")
            clay.TextDynamic(
                text,
                clay.TextConfig({ textColor = font_color, fontSize = 20 ,textAlignment = .Right,letterSpacing=3,fontId = 1}),

            )
        }
        uibt_back()
        
        ui_ex_pading()
    }
}
uibt_back::proc(){
    if clay.UI()({
        id = clay.ID("back"),
        layout = {
            sizing = { width = clay.SizingGrow({}) },
            padding = { 16, 16, 16, 16 },
            childGap = 16,
            childAlignment = { y = .Center ,x = .Center},
        },
        backgroundColor = clay.Hovered()?c_red_hov:c_red,
        cornerRadius = { 6, 6, 6, 6 },
    }){
        if clay.Hovered(){
            g.ui_st.last_e_hov = 400
            if clay.Hovered()&& rl.IsMouseButtonPressed(.LEFT){
                if g.ui_st.b_page == .mode_sulect{
                    g.ui_st.b_page = .start
                }
                if g.ui_st.b_page == .setings{
                    g.ui_st.b_page = .game
                }
                play_sound(.s_click,4,.75)
            
            }
        }
        text :=fmt.tprint("Back")
        clay.TextDynamic(
            text,
            clay.TextConfig({ textColor = font_color, fontSize = 20 ,textAlignment = .Right,letterSpacing=3,fontId = 1}),

        )
    }
}

ui_game_over::proc(){
    if g.game_over{
        if g.ui_st.b_page ==.game{
            ui_ex_pading()
            uibt_restart()
            uibt_main_menu()
            ui_ex_pading()
        }
    }
}

ui_setings::proc(){
    if g.ui_st.b_page ==.setings{
        ui_ex_pading()
        uibt_restart()
        uibt_main_menu()
        uibt_back()
        ui_ex_pading()
    }
}

uibt_restart::proc(){
    if clay.UI()({
        id = clay.ID("restart"),
        layout = {
            sizing = { width = clay.SizingGrow({}) },
            padding = { 16, 16, 16, 16 },
            childGap = 16,
            childAlignment = { y = .Center ,x = .Center},
            
        },
        backgroundColor = clay.Hovered()?c_red_hov:c_red,
        cornerRadius = { 6, 6, 6, 6 },
        
    }){ 
        if clay.Hovered(){
        g.ui_st.last_e_hov = 405
            if rl.IsMouseButtonPressed(.LEFT){
                g.ui_st.b_page = .mode_sulect
                play_sound(.s_click,4,.75)
                restart_game()
                g.mode = .display
            }
        }

        text :=fmt.tprint("Restart")
        clay.TextDynamic(
            text,
            clay.TextConfig({ textColor = font_color, fontSize = 20 ,textAlignment = .Right,letterSpacing=3,fontId = 1}),

        )
    }
}
uibt_main_menu::proc(){
    if clay.UI()({
        id = clay.ID("main_menu"),
        layout = {
            sizing = { width = clay.SizingGrow({}) },
            padding = { 16, 16, 16, 16 },
            childGap = 16,
            childAlignment = { y = .Center ,x = .Center},
            
        },
        backgroundColor = clay.Hovered()?c_red_hov:c_red,
        cornerRadius = { 6, 6, 6, 6 },
    }){ 
        if clay.Hovered(){
        g.ui_st.last_e_hov = 405
            if rl.IsMouseButtonPressed(.LEFT){
                g.ui_st.b_page = .mode_sulect
                play_sound(.s_click,4,.75)
                restart_game()
                g.ui_st.b_page = .start
                g.mode = .display
            }
        }

        text :=fmt.tprint("Main Menu")
        clay.TextDynamic(
            text,
            clay.TextConfig({ textColor = font_color, fontSize = 20 ,textAlignment = .Right,letterSpacing=3,fontId = 1}),

        )
    }
}
ui_hov_sound::proc(){
    if g.ui_st.last_f_e_hov != g.ui_st.last_e_hov{
        play_sound(.s_click,3,1.75)
    }
    g.ui_st.last_f_e_hov = g.ui_st.last_e_hov
}
