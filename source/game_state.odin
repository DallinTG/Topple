package game

import "core:fmt"
import "core:math"
import "core:math/rand"
import b2 "box2d"
import rl "vendor:raylib"
import "base:runtime"

state::struct{
	particle:all_particle_data,
	lights:[max_lights]light,
	entity_bucket:entity_bucket, //contains all entities
	game_map:game_map,
	seeds:seeds,
	// resources:[dynamic]item_slot,
	// ecs:ecs.Context,
    block_pos:[2]f32,
    block_rot:f32,
    block:entity_index,
    next_block:entity_index,
    block_spin:f32,
    block_drop_speed_m:f32,
    h_pos:f32,
    ch_pos:f32,
    lh_pos:f32,
    sh_pos:f32,
    score:i32,
    yb_time:f32,
    block_spawn_cd:f32,
    life:i32,
    last_f_life:i32,
    life_score:i32,
    game_over:bool,
    game_over_delay:f32,
    puzlel_lazer_h:f32,
    puzlel_lazer_color_shift:f32,
    
    
}
puzlel_lazer_color:[4]u8:{50, 252, 59,200}
puzlel_lazer_color_danger:[4]u8:{252, 50, 50,200}
block_size::16
block_drop_speed::75
block_destroy_lev::100
screane_spaceing::400

g_mode::enum{
    display=0,
    endless=8,
    puzzle=7,
}
cloude::struct{
    imag:img_ani_name,
    pos:[2]f32,
    speed:f32,
    tint:rl.Color,
}


do_gamestate::proc(){
    update_block()
    manage_score()
	manage_cam()
    do_puzll_mode_checks()
	// if rl.IsMouseButtonDown(.LEFT){
	// 	create_entity_by_id_box2d(.bace,{0,-300})
	// }
	// if rl.IsMouseButtonDown(.RIGHT){
	// 	create_entity_by_id_box2d(.B_Block,{0,-300})
	// }
    manage_game_state()
}
manage_game_state::proc(){
    g.ch_pos = 0
    g.h_pos = 0
    g.yb_time = 10
    if !dos_entity_exist(g.block) {
        if g.life < 1 {
            g.game_over_delay+= g.time.dt
        }

    }
    if g.game_over_delay > 2{
        g.game_over = true
        if g.game_over_delay < 3{
            g.game_over_delay+=1
            play_sound(.wa_wa,1,1.4)
            // play_sound(.wa_wa,1,1.3)
            play_sound(.wa_wa,1,1.2)
        }
    }
}
update_block::proc(){
    block :=get_entity_by_index(g.block)
    // d_data:=&g.defalt.ent_init_data[block.name]
    if block!=nil{
        if g.time.dt < 0.1{
            g.block_pos.y+=block_drop_speed*g.block_drop_speed_m*g.time.dt
        }
        b2.Body_SetLinearVelocity(block.body_id,{0,0})
        b2.Body_SetAngularVelocity(block.body_id,0)
        b_pos_2:=b2.Body_GetWorldCenterOfMass(block.body_id)
        b_pos:=b2.Body_GetWorldPoint(block.body_id,{-block_size/2*cast(f32)block.w_h.x+(block_size/2),-block_size/2*cast(f32)block.w_h.y+(block_size/2)})
        b_rot:=b2.Rot_GetAngle(b2.Body_GetRotation(block.body_id))*rl.RAD2DEG
        g.block_spin = 1
        if b_rot < g.block_rot{g.block_spin=1}
        if b_rot > g.block_rot{g.block_spin=-1}
        vec:[2]f32={(g.block_pos.x-b_pos.x),(g.block_pos.y-b_pos.y)}

        rot_dif:f32=math.abs((g.block_rot-b_rot))*g.block_spin
        if rot_dif >180{
            rot_dif=rot_dif-360
        }
        if rot_dif <-180{
            rot_dif=rot_dif+360
        }
    
        if g.time.dt < 0.1{
            fps:=rl.GetFPS()
            m:f32=1
            if fps < 100{m=.5}
            if fps < 50{m=.2}
            b2.Body_ApplyLinearImpulseToCenter(block.body_id,vec*15000*m,true)
            // b2.Body_ApplyTorque(block.body_id,rot_dif*5000000,true)
            // b2.Body_SetTransform(block.body_id,g.block_pos,b2.MakeRot(g.block_rot*rl.DEG2RAD))
            // b2.Body_ApplyAngularImpulse(block.body_id,rot_dif*rl.DEG2RAD*10000000,true)
            b2.Body_SetAngularVelocity(block.body_id,rot_dif*rl.DEG2RAD*10)
        }
    
        shape_ary:[36]b2.ShapeId
        _=b2.Body_GetShapes(block.body_id,shape_ary[:])
        for &shape in &shape_ary{
            if b2.Shape_IsValid(shape){
                poly:=b2.Shape_GetPolygon(shape)
                b2.World_OverlapPolygon(g.box_2d_world_id,poly,b2.Body_GetTransform(block.body_id),b2.DefaultQueryFilter(),on_block_colide,cast(rawptr)&shape)
            
            }
        }
    }else{
        if g.block_spawn_cd>.4{
            g.block_spawn_cd=0

        set_new_block()

        }else{
            g.block_spawn_cd+=g.time.dt
        }
    }
}
on_block_colide::proc"cdecl"(shape_id:b2.ShapeId,data:rawptr)->bool{
    context = runtime.default_context()
    shape_id_2 :=(cast(^b2.ShapeId)(data))^
    ent_1_id := cast(u32)cast(uintptr)b2.Shape_GetUserData(shape_id)
    ent_2_id := cast(u32)cast(uintptr)b2.Shape_GetUserData(shape_id_2)
    if shape_id != shape_id_2{
        if ent_1_id!=ent_2_id{
            
            body_id:=b2.Shape_GetBody(shape_id_2)
            b2.Body_SetLinearVelocity(b2.Shape_GetBody(shape_id),{0,0})
            b2.Body_SetLinearVelocity(b2.Shape_GetBody(shape_id_2),{0,0})
            b2.Body_SetLinearVelocity(b2.Shape_GetBody(shape_id),{0,0})
            b2.Body_SetLinearVelocity(b2.Shape_GetBody(shape_id_2),{0,0})

            if g.block.id ==  ent_2_id{
                drop_block(body_id)
                // play_sound(.s_thud,.75,1.5)
            }
            g.block = {0,0}

        }
    }
    return true
}
drop_block::proc(body_id:b2.BodyId){
    context = runtime.default_context()
    ent:=get_entity_by_index(g.block) 
    d_data:=ent.init_data
    shape_ary:[36]b2.ShapeId
    _=b2.Body_GetShapes(body_id,shape_ary[:])
    for &shape in &shape_ary{
        if b2.Shape_IsValid(shape){
            b2.DestroyShape(shape)
        }
    }
    if g.mode !=.display{
        play_sound(.s_thud,.75,1.5)

    }
    
    add_shapes_to_body_from_block_shape(d_data,g.block,body_id,0)
    g.block = {0,0}
}

restart_game::proc(){
    delete_all_entitys()
    g.st = {}
    g.puzlel_lazer_h=-200
    g.block_pos={0,g.h_pos-screane_spaceing}
    set_new_block()
    g.cam.position.y = -250
    g.cam.target.y = g.cam.position.y
    // create_entity_by_id_box2d(.platform,{0,0})
    // create_entity_by_id_box2d(.platform,{0,0})
    create_platform()
    g.life=4
    g.last_f_life=g.life
}
create_platform::proc(){
    create_entity_by_id_box2d(.platform,{block_size*2.5,0})
}
set_new_block::proc(){
    if g.life>0{
        g.block_pos={0,g.h_pos-screane_spaceing}
        g.block_rot=0
        if dos_entity_exist(g.next_block){
        g.block = g.next_block
        block:=get_entity_by_index(g.block)
        block.is_inactiv = false
        b2.Body_SetTransform(block.body_id,g.block_pos,b2.MakeRot(0))
        g.next_block=create_entity_by_id_box2d(.b_block,{10000,10000})
        n_block:=get_entity_by_index(g.next_block)
        n_block.is_inactiv = true
        }else{
            g.block=create_entity_by_id_box2d(.b_block,g.block_pos)
            g.next_block=create_entity_by_id_box2d(.b_block,{10000,10000})
            n_block:=get_entity_by_index(g.next_block)
            n_block.is_inactiv = true
        }
    }
}
draw_block_gyde_guidelines::proc(){
    if g.mode !=.display{
        block :=get_entity_by_index(g.block)

        if block!=nil{
            // b_pos:=b2.Body_GetPosition(block.body_id)
            b_pos:=b2.Body_GetWorldPoint(block.body_id,{-block_size/2*cast(f32)block.w_h.x+(block_size/2),-block_size/2*cast(f32)block.w_h.y+(block_size/2)})
            width:=cast(f32)block.w_h.y*block_size
            hight:=cast(f32)block.w_h.x*block_size
            if g.block_rot == 0 || g.block_rot == 180{
                width=cast(f32)block.w_h.x*block_size
                hight=cast(f32)block.w_h.y*block_size
            }
            // rl.DrawRectangle(cast(i32)g.block_pos.x-(width/2),cast(i32)g.block_pos.y,width,2000,{255,255,255,55})
            draw_image(.Tile,{b_pos.x-cast(f32)(width/2),b_pos.y-hight/2,width,2000,},5,{0,0},0,{255,255,255,55})
        }
    }
}

block_logic::proc(block:^entity){
    b_pos:=b2.Body_GetPosition(block.body_id)
    
    
    if block.time >1{
        if b_pos.y < g.h_pos{
            g.h_pos=b_pos.y
        }
    }
    if b_pos.y < g.ch_pos{
        g.lh_pos = g.ch_pos
        g.ch_pos=b_pos.y
        // g.cam.position.y=g.ch_pos
        // g.cam.target.y=g.ch_pos
    }
    if block.time < g.yb_time{
        g.yb_time = block.time
    }

    if b_pos.y> block_destroy_lev{
        delete_block(block)
    }
    g.score +=block.score

}
delete_block::proc(block:^entity){
    play_sound(.s_pop,.5,.5)
    play_sound(.s_pop,.25,.1)
    play_sound(.no_1,.25,.75)
    p:particle
    p.img = block.imag
    p.pos.xy = b2.Body_GetWorldPoint(block.body_id,{-block_size/2*cast(f32)block.w_h.x+(block_size/2),-block_size/2*cast(f32)block.w_h.y+(block_size/2)})
    for i in 0..=50+rand.int31_max(10){
        p.life=rand.float32_beta(.5,1)
        p.max_life=rand.float32_beta(.5,1)
        p.velocity.xy={100*((rand.float32()*2)-1),100*((rand.float32()*2)-1)}
        p.tint = rl.ColorNormalize(block.tint)
        p.w_h=block_size*(rand.float32()+.5)/2
        p.w_h_shift = p.w_h*-1
        add_particle(p)
    }
    if g.mode !=.display{
        g.life-=1
        g.life_score+=block.score
    }
    delete_entity(block.entity_index) 
}

manage_score::proc(){
    g.score = 0
    block :=get_entity_by_index(g.block)
    if block != nil{
        g.score -= block.score
    }

}
manage_cam::proc(){
    if g.mode!=.display{
    // if g.ch_pos+screane_spaceing/2 < g.h_pos{
    //     g.cam.position.y=g.ch_pos+screane_spaceing/2
    //     g.cam.target.y=g.ch_pos+screane_spaceing/2
    // }
        if g.block_pos.y> g.cam.position.y+screane_spaceing/2/1.5{
            // g.cam.position.y=g.block_pos.y-screane_spaceing/2
            // g.cam.target.y=g.block_pos.y-screane_spaceing/2

            g.cam.position.y+=((g.block_pos.y-screane_spaceing/2/1.5)-g.cam.position.y)*g.time.dt
            g.cam.target.y=g.cam.position.y
        }
        if g.block_pos.y< g.cam.position.y-screane_spaceing/2{
            g.cam.position.y+=((g.block_pos.y+screane_spaceing/2)-g.cam.position.y)*g.time.dt

            // g.cam.position.y=g.block_pos.y+screane_spaceing/2
            g.cam.target.y=g.cam.position.y
        }
    }
    
}
back_g_wh:[2]f32:{384,216}
back_g_h_ofset:[2]f32:{200,200}
bg_cloud_shift:f32=0
bg_cloud_shift_2:f32=0
bg_m_shift:f32=0
draw_background::proc(){

    if bg_cloud_shift > back_g_wh.x{bg_cloud_shift-=back_g_wh.x}
    if bg_cloud_shift_2 > back_g_wh.x{bg_cloud_shift_2-=back_g_wh.x}
    if bg_m_shift > back_g_wh.x{bg_m_shift-=back_g_wh.x}
    bg_cloud_shift+=g.time.dt * 5
    bg_cloud_shift_2+=g.time.dt * 6
    bg_m_shift+=g.time.dt * 2
    draw_cloudes()
    //cloud
    for i in 0..=6 {
        draw_image(
            name=.Background_Cloudes,
            dest={(back_g_wh.x*cast(f32)i*2)+(bg_cloud_shift_2*2)+(-(back_g_wh.x*2)*4)-100,-60,back_g_wh.x*2,back_g_wh.y*2},
            z=13,
            tint={220,220,255,100}
        )
    }
    
    //cloud
    for i in 0..=6 {
        draw_image(
            name=.Background_Cloudes,
            dest={(back_g_wh.x*cast(f32)i*2)+(bg_cloud_shift*2)+(-(back_g_wh.x*2)*4),-25,back_g_wh.x*2,back_g_wh.y*2},
            z=12,
            tint={255,255,255,100}
        )
    }
    //mounton
    for i in 0..=6 {
        draw_image(
            name=.Background_Glacial_Mountains,
            dest={
                0+(back_g_wh.x*cast(f32)i*2)+(-(back_g_wh.x*2)*4)+(bg_m_shift*2),
                0,
                back_g_wh.x*2,
                back_g_wh.y*2
            },
            z=11,
            tint={255,255,255,255}
        )
    }

    //cloud
    for i in 0..=6 {
        draw_image(
            name=.Background_Cloudes,
            dest={(back_g_wh.x*cast(f32)i*2)+(bg_cloud_shift_2*2)+(-(back_g_wh.x*2)*4)-100,180,back_g_wh.x*2,back_g_wh.y*2},
            z=10.5,
            tint={255,255,255,100}
        )
    }
    //cloud
    for i in 0..=6 {
        draw_image(
            name=.Background_Cloudes,
            dest={(back_g_wh.x*cast(f32)i*2)+(bg_cloud_shift*2)+(-(back_g_wh.x*2)*4)+100,200,back_g_wh.x*2,back_g_wh.y*2},
            z=10.2,
            tint={220,220,255,100}
        )
    }
    //mounton
    for i in 0..=6 {
        draw_image(
            name=.Background_Glacial_Mountains,
            dest={
                0+(back_g_wh.x*cast(f32)i*2)+(-(back_g_wh.x*2)*4)+(bg_m_shift*2),
                0+back_g_h_ofset.y,
                back_g_wh.x*2,
                back_g_wh.y*2
            },
            z=10,
            tint={255,255,255,255}
        )
    }

    //mounton
    for i in 0..=6 {
        draw_image(
            name=.Background_Glacial_Mountains,
            dest={
                0+(back_g_wh.x*cast(f32)i*2)+(-(back_g_wh.x*2)*4)+(bg_m_shift*2),
                0+back_g_h_ofset.y+290,
                back_g_wh.x*2,
                back_g_wh.y*2
            },
            z=10,
            tint={255,255,255,255}
        )
    }
    for i in 0..=6 {
        draw_image(
            name=.Background_Glacial_Mountains,
            dest={
                0+(back_g_wh.x*cast(f32)i*2)+(-(back_g_wh.x*2)*4)+(bg_m_shift*2),
                0+back_g_h_ofset.y+580,
                back_g_wh.x*2,
                back_g_wh.y*2
            },
            z=10,
            tint={255,255,255,255}
        )
    }
    for i in 0..=6 {
        draw_image(
            name=.Background_Glacial_Mountains,
            dest={
                0+(back_g_wh.x*cast(f32)i*2)+(-(back_g_wh.x*2)*4)+(bg_m_shift*2),
                0+back_g_h_ofset.y,
                back_g_wh.x*2,
                back_g_wh.y*15
            },
            z=20,
            tint={255,255,255,255}
        )
    }


}

draw_cloudes::proc(){
    for &cloude in &g.cloudes{
        if cloude.imag != nil{
            draw_image(
                name=cloude.imag,
                dest={cloude.pos.x,cloude.pos.y,atlas_textures[cloude.imag.(Texture_Name)].rect.width*2,atlas_textures[cloude.imag.(Texture_Name)].rect.height*2},
                z=15,
                tint=cloude.tint
            )
            if cloude.pos.x >3500{
                cloude.pos.x = -3500
            }
            cloude.pos.x+=g.time.dt*cloude.speed*3
        }
    }
}

draw_health::proc(){
    if g.ui_st.b_page==.game{
        for i in 0..<g.life{
            draw_image(name=.Heart,dest={g.block_pos.x,g.block_pos.y,block_size,block_size},origin={0-(block_size/2),100},rot=11.25*cast(f32)i,z = -16)
        }
        if g.last_f_life>0{
            if g.last_f_life>g.life{ 
                p:particle
                p.img = .Heart
                p.pos.xy = {g.block_pos.x,g.block_pos.y}
                p.origin_offset={0,100}
                p.rot = 11.25*cast(f32)g.last_f_life
                for i in 0..=10+rand.int31_max(10){
                    p.life=rand.float32_beta(.5,1)
                    p.max_life=rand.float32_beta(.5,1)
                    p.velocity.xy={100*((rand.float32()*2)-1),100*((rand.float32()*2)-1)}
                    p.tint = rl.ColorNormalize({255,255,255,255})
                    p.w_h=block_size*(rand.float32()+.5)/2
                    p.w_h_shift = p.w_h*-1
                    add_particle(p)
                }
            }
            if g.last_f_life<g.life{ 
                p:particle
                p.img = .Heart
                p.pos.xy = {g.block_pos.x,g.block_pos.y}
                p.origin_offset={0,100}
                p.rot = 11.25*cast(f32)g.last_f_life+1
                for i in 0..=10+rand.int31_max(10){
                    p.life=rand.float32_beta(.5,1)
                    p.max_life=rand.float32_beta(.5,1)
                    p.velocity.xy={100*((rand.float32()*2)-1),100*((rand.float32()*2)-1)}
                    p.tint = rl.ColorNormalize({255,255,255,255})
                    p.w_h=block_size*(rand.float32()+.5)/2
                    p.w_h_shift = p.w_h*-1
                add_particle(p)
                }
            }
        }
    }
    g.last_f_life = g.life
}

do_puzll_mode_checks::proc(){
    if g.mode==.puzzle{
        box:=b2.MakeBox(1600,16)
        b2.World_OverlapPolygon(g.box_2d_world_id,box,{{0,g.puzlel_lazer_h-4},b2.MakeRot(0)},b2.DefaultQueryFilter(),puzll_colide,nil)
    }
}
puzll_colide::proc"cdecl"(shape_id:b2.ShapeId,data:rawptr)->bool{
    context = runtime.default_context()
    colid_body:=b2.Shape_GetBody(shape_id)
    ent := get_entity_by_index(g.block)
    do_colide:bool = false
    if ent!=nil{
        if ent.body_id !=colid_body{
            do_colide=true
        }else{
            do_colide=false
        }
    }else{do_colide=true}
    if do_colide{
        us_data:=cast(^entity)b2.Body_GetUserData(colid_body)
        if us_data!=nil{
            if dos_entity_exist(us_data.entity_index){
                g.puzlel_lazer_color_shift+=g.time.dt
                if g.puzlel_lazer_color_shift >1{
                    us_data.in_danger_time+=g.time.dt
                    if us_data.in_danger_time > .5{

                        delete_block(us_data)
                    }
                }
            }
        }
    }
    return true
}
puzzle_lazer_shift:f32
draw_puzle_mode_stuff::proc(){
    if g.mode==.puzzle{
        if puzzle_lazer_shift > 512{puzzle_lazer_shift-=512}
        puzzle_lazer_shift +=g.time.dt*50
        // draw_image(.Big_Lazer,{2600/2*-1,-200,2600,16})
        g.puzlel_lazer_color_shift-=g.time.dt/2
        if g.puzlel_lazer_color_shift< 0 {g.puzlel_lazer_color_shift = 0}
        for i in 0..=12 {
            draw_image(
                name=.Big_Lazer,
                dest={(512*cast(f32)i)+(puzzle_lazer_shift)+(-(512*2)*2),g.puzlel_lazer_h+4,512,16},
                z=-12,
                tint=rl.ColorLerp(cast(rl.Color)puzlel_lazer_color,cast(rl.Color)puzlel_lazer_color_danger,g.puzlel_lazer_color_shift)
            )
        }
    }
}
t_s_stuf::struct{
    ts_wh_m:f32,
    ts_wh:f32,
    ts_h_m:f32,
    ts_h:f32,
    ts_r_m:f32,
    ts_r:f32,
}

draw_title_screane::proc(){
    
    g.t_s_stuf.ts_h+=g.time.dt*1.5
    g.t_s_stuf.ts_wh+=g.time.dt
    g.t_s_stuf.ts_r+=g.time.dt
    if g.mode ==.display{
    draw_image(
        name=.Topple,
        dest={0,((math.sin(g.t_s_stuf.ts_h)/2)+.5)*50-480,106*4,48*4},
        origin={106*4/2,48*4/2},
        z=-12,
        rot=cast(f32)math.lerp(cast(f32)-15,cast(f32)15,(math.sin(g.t_s_stuf.ts_r)/2)+.5),
        tint={255,255,255,255}
    )
    }
}