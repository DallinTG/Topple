package game

import rl "vendor:raylib"
import "core:math"
import "core:math/rand"
import "core:fmt"

time_stuff::struct{
    dt:f32,
    dt_60h:f32,
    is_60h_this_frame:bool,
    frame_count_60h:i32,
    frame_count:uint,

}

mantine_timers::proc(){
    
    g.time.dt = rl.GetFrameTime()
    g.time.dt_60h += rl.GetFrameTime()
    g.time.frame_count+=1
    if g.time.is_60h_this_frame == true{
        g.time.is_60h_this_frame = false
        g.time.dt_60h -=0.016666    }
    if g.time.dt_60h >0.016666{
        g.time.is_60h_this_frame = true
        g.time.frame_count_60h+=1
    }
}
lerp_colors::proc(c1:[4]f32,c2:[4]f32,m:f32)->(f_color:[4]f32){
    f_color ={ math.lerp(c1.r,c2.r,m),math.lerp(c1.g,c2.g,m),math.lerp(c1.b,c2.b,m),math.lerp(c1.a,c2.a,m)}
    return
}
init_defalt_settings::proc(){
    g.settings.render_distance = 3
}
init_seeds::proc(){
    g.st.seeds.bace = rand.int63()
    g.st.seeds.height = rand.int63()
    g.st.seeds.ore = rand.int63()
}


do_inputs::proc(){
    check_cam_movements()
    check_paning()
    check_fov()
}
min_zoom::64
max_zoom::2048
check_fov::proc(){
    g.cam.fovy +=rl.GetMouseWheelMove()*tile_size*-2
    if g.cam.fovy < min_zoom {g.cam.fovy = min_zoom}
    if g.cam.fovy > max_zoom {g.cam.fovy = max_zoom}
}



check_cam_movements::proc(){
    block_speed:f32=.5
    if g.ui_st.b_page == .game && !g.game_over{
        if rl.IsKeyDown(.LEFT_SHIFT){
            block_speed = 1
        }
        if rl.IsKeyPressed(.R)||rl.IsKeyPressed(.E) ||rl.IsMouseButtonPressed(.MIDDLE){
            g.block_rot+=90
            if dos_entity_exist(g.block){

                play_sound(.woosh,1,.7)
            }
        }
        if rl.IsKeyPressed(.Q){//||rl.IsMouseButtonPressed(.LEFT){
            g.block_rot-=90
            if dos_entity_exist(g.block){
                play_sound(.woosh,1,1.2)
            }
        }
        // if rl.IsKeyPressed(.UP) || rl.IsKeyPressed(.W) {
        //     g.block_pos+={block_size*0,block_size*-block_speed}
        // }
        if rl.IsKeyPressed(.SPACE){
            if dos_entity_exist(g.block){
                ent:=get_entity_by_index(g.block)
                drop_block(ent.body_id)
            }
        }
        if rl.IsKeyPressed(.LEFT) || rl.IsKeyPressed(.A) {
            if dos_entity_exist(g.block){
                g.block_pos+={block_size*-block_speed,block_size*0}
                play_sound(.woosh,.7*block_speed,1.2)
                play_sound(.woosh,.7*block_speed,1.5-block_speed)
            }

        }
        if rl.IsKeyPressed(.RIGHT) || rl.IsKeyPressed(.D) {
            if dos_entity_exist(g.block){
                g.block_pos+={block_size*block_speed,block_size*0}
                play_sound(.woosh,.7*block_speed,1)
                play_sound(.woosh,.7*block_speed,1.5-block_speed)
            }
        } 
    }
    if rl.IsKeyPressed(.ESCAPE){
        if g.ui_st.b_page==.setings{
            g.ui_st.b_page=.game
            return
            
        }
        if g.ui_st.b_page==.game{
            g.ui_st.b_page=.setings
            return
        }
        fmt.print(g.ui_st.b_page,"\n")
    }

	if rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.S) && g.ui_st.b_page == .game {
        // g.block_pos+={block_size*0,block_size*block_speed}
        g.block_drop_speed_m = 2*(block_speed*2)
	}else{
        g.block_drop_speed_m = 1
    }
    if g.block_rot >= 360{g.block_rot=0}
    if g.block_rot < 0{g.block_rot=270}


    g.cam.target.xy = g.cam.position.xy

}


check_paning::proc(){
    
	// if rl.IsMouseButtonDown(.RIGHT) {
        
	// 	delta:rl.Vector2 = rl.GetMouseDelta()
	// 	delta = (delta *(g.cam.fovy/cast(f32)rl.GetScreenHeight())*-1 )
	// 	g.cam.position += {delta.x,delta.y,0}
	// 	g.cam.target.x = g.cam.position.x
	// 	g.cam.target.y = g.cam.position.y

	// }
}

