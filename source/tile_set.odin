#+feature dynamic-literals
package game

// import rl "vendor:raylib"
import "core:fmt"
import rl "vendor:raylib"
import noise"core:math/noise"
tile_set_names::enum{
    None,
    Bace_Rock,
    Bace_Sand,
    Lava,
    Copper_Ore_T,
    Iron_Ore_T,
    Stone_Ore_T,
    Coal_Ore_T,
}
tile_flags::enum{
    can_not_build_on,
}
tile_set::struct{
    img:img_ani_name,
    tint:rl.Color,
    flags:bit_set[tile_flags],
    mineable_item:item_names,
    t_required_to_mine:i32,
}
defalt_tile_sets:=[tile_set_names]tile_set{
    .None = {},
    .Bace_Rock = {
        // img=.Bace_Rock,
        tint={255, 255, 255,255},
    },
    .Bace_Sand = {
        // img=.Bace_Sand,
        tint={255, 255, 255,255},
        mineable_item=.sand,
        t_required_to_mine=0,
    },
    .Lava = {
        // img=.Lava,
        tint={255, 255, 255,255},
        flags={.can_not_build_on},
    },
    .Copper_Ore_T = {
        // img=.Ore_Bace,
        tint={232, 130, 14,255},
        mineable_item=.ore_copper,
        t_required_to_mine=1,
    },
    .Iron_Ore_T = {
        // img=.Ore_Bace,
        tint={194, 198, 204,255},
        mineable_item=.ore_iron,
        t_required_to_mine=1,
    },
    .Stone_Ore_T = {
        // img=.Ore_Bace,
        tint={161, 136, 96,255},
        mineable_item=.ore_stone,
        t_required_to_mine=1,
    },
    .Coal_Ore_T = {
        // img=.Ore_Bace,
        tint={20, 4, 0,255},
        mineable_item=.ore_coal,
        t_required_to_mine=1,
    },
}
tile::struct{
    l1:tile_set_names,
    l2:tile_set_names,
    building:entity_index,
}
tile_map::struct{
    data:[tile_map_size]#soa[tile_map_size]tile,
    is_disabled:bool,
}
game_map::struct{
    tile_maps:map[[2]int]tile_map,
    
}

tile_map_size::16
tile_size::16
t_map:tile_map



draw_tile_map::proc(tile_map:^tile_map,pos:[3]int){
    if tile_map != nil{
        ofset:[2]int={
            tile_size*pos.x*tile_map_size,
            tile_size*pos.y*tile_map_size,
        }
        for &row,x in &tile_map.data{
            for &tile,y in &row{
                draw_image(
                    defalt_tile_sets[tile.l1].img,
                    {
                        cast(f32)(x*tile_size+ofset.x)+.005,
                        cast(f32)(y*tile_size+ofset.y)+.005,
                        tile_size+.01,
                        tile_size+.01,
                    },
                    0,
                    tint=defalt_tile_sets[tile.l1].tint
                )
                draw_image(
                    defalt_tile_sets[tile.l2].img,
                    {
                        cast(f32)(x*tile_size+ofset.x),
                        cast(f32)(y*tile_size+ofset.y),
                        tile_size,
                        tile_size,
                    },
                    0,
                    tint=defalt_tile_sets[tile.l2].tint
                )

            }
        }
        for &row,x in &tile_map.data{
            for &tile,y in &row{
            }
        }
    }
}
fill_tile_map::proc(tile_map:^tile_map,tile_id:tile_set_names){
    for &row,x in &tile_map.data{

        for &tile,y in &row{
            
            set_tile_l1_in_tile_map(tile_map,tile_id,{cast(i32)x,cast(i32)y})
            // set_tile_l2_in_tile_map(tile_map,.copper_ore_t,{cast(i32)x,cast(i32)y})
        }
    }
}
fill_tile_map_by_x_y::proc(x:int,y:int,tile_id:tile_set_names){
    t_map:tile_map={}
    g.st.game_map.tile_maps[{x,y}] = t_map
    fill_tile_map(&g.st.game_map.tile_maps[{x,y}],tile_id)


}
set_tile_in_tile_map::proc(tile_map:^tile_map,tile:tile,pos:[2]i32){
    tile_map.data[pos.x][pos.y] = tile
}
set_tile_l1_in_tile_map::proc(tile_map:^tile_map,tile:tile_set_names,pos:[2]i32){
    tile_map.data[pos.x][pos.y].l1 = tile
}
set_tile_l2_in_tile_map::proc(tile_map:^tile_map,tile:tile_set_names,pos:[2]i32){
    tile_map.data[pos.x][pos.y].l2 = tile
}
set_tile_building_in_tile_map::proc(tile_map:^tile_map,tile:entity_index,pos:[2]i32){
    tile_map.data[pos.x][pos.y].building = tile
}
draw_game_map_full::proc(){
    for x_y ,&t_map in &g.st.game_map.tile_maps{
        if !t_map.is_disabled {
            draw_tile_map_by_x_y(x_y.x,x_y.y)
        }
    }
}
draw_game_map::proc(){

    ray_top_l :=rl.GetScreenToWorldRay({0,0},g.cam)
    ray_bot_r :=rl.GetScreenToWorldRay({cast(f32)rl.GetScreenWidth(),cast(f32)rl.GetScreenHeight()},g.cam)
    g_pos_l:=t_pos_g_pos(world_pos_t_pos({cast(f32)ray_top_l.position.x,cast(f32)ray_top_l.position.y}))
    g_pos_r:=t_pos_g_pos(world_pos_t_pos({cast(f32)ray_bot_r.position.x,cast(f32)ray_bot_r.position.y}))
    for x := g_pos_l.x; x <g_pos_r.x+1; x += 1 {
        for y := g_pos_l.y; y <g_pos_r.y+1; y += 1 {
            tile_map:=&g.st.game_map.tile_maps[{x,y}]
            if tile_map == nil{
                // fill_tile_map_by_x_y(x,y,.Bace_Rock)
                gen_tile_map_by_x_y(x,y)
            }
            draw_tile_map_by_x_y(x,y)
        }
    }
}
gen_tile_map_by_x_y::proc(x:int,y:int){
    g.st.game_map.tile_maps[{x,y}] = t_map
    tile_map:=&g.st.game_map.tile_maps[{x,y}]
    // tile_map.is_disabled = true
    g_pos:[2]int={x,y}
    for &row,x in &tile_map.data{
        for &tile,y in &row{
            height:=noise.noise_2d_improve_x(g.st.seeds.height,{(cast(f64)x+cast(f64)(g_pos.x*tile_map_size))/100,(cast(f64)y+cast(f64)(g_pos.y*tile_map_size))/100})
            if  height>-.5{
                set_tile_l1_in_tile_map(tile_map,.Bace_Rock,{cast(i32)x,cast(i32)y})
                // tile_map.is_disabled = false
            }else if height>-.8{
                set_tile_l1_in_tile_map(tile_map,.Bace_Sand,{cast(i32)x,cast(i32)y})
                // tile_map.is_disabled = false
            }else{
                set_tile_l1_in_tile_map(tile_map,.Lava,{cast(i32)x,cast(i32)y})
                // tile_map.is_disabled = false
            }
            if  height>-.4{
                ore_h:=noise.noise_2d_improve_x(g.st.seeds.height*g.st.seeds.height,{(cast(f64)x+cast(f64)(g_pos.x*tile_map_size))/100,(cast(f64)y+cast(f64)(g_pos.y*tile_map_size))/100})
                if ore_h>.9||ore_h<-.9{
                    set_tile_l2_in_tile_map(tile_map,.Copper_Ore_T,{cast(i32)x,cast(i32)y})
                }
                ore_h=noise.noise_2d_improve_x(g.st.seeds.height*g.st.seeds.height+2956036859234605456*g.st.seeds.height,{(cast(f64)x+cast(f64)(g_pos.x*tile_map_size))/100,(cast(f64)y+cast(f64)(g_pos.y*tile_map_size))/100})
                if ore_h>.9||ore_h<-.9{
                    set_tile_l2_in_tile_map(tile_map,.Iron_Ore_T,{cast(i32)x,cast(i32)y})
                }
                ore_h=noise.noise_2d_improve_x(g.st.seeds.height*g.st.seeds.height+8987384524576585644*g.st.seeds.height,{(cast(f64)x+cast(f64)(g_pos.x*tile_map_size))/100,(cast(f64)y+cast(f64)(g_pos.y*tile_map_size))/100})
                if ore_h>.9||ore_h<-.9{
                    set_tile_l2_in_tile_map(tile_map,.Stone_Ore_T,{cast(i32)x,cast(i32)y})
                }
                ore_h=noise.noise_2d_improve_x(g.st.seeds.height*g.st.seeds.height+7845234845689023475*g.st.seeds.height,{(cast(f64)x+cast(f64)(g_pos.x*tile_map_size))/100,(cast(f64)y+cast(f64)(g_pos.y*tile_map_size))/100})
                if ore_h>.9||ore_h<-.9{
                    set_tile_l2_in_tile_map(tile_map,.Coal_Ore_T,{cast(i32)x,cast(i32)y})
                }
            }
        }
    }
}
draw_tile_map_by_x_y::proc(x:int,y:int){
    tile_map := &g.st.game_map.tile_maps[{x,y}]
    draw_tile_map(
        tile_map,
        {
            x,
            y,
            10,
        },
    )
}
world_pos_t_pos::proc(pos:[2]f32)->(t_pos:[2]int){
    n_pos:=pos
    if n_pos.x<0{
        n_pos.x-=tile_size
    }
    if n_pos.y<0{
        n_pos.y-=tile_size
    }
    t_pos={cast(int)n_pos.x,cast(int)n_pos.y}/tile_size
    return t_pos
}
t_pos_l_pos::proc(t_pos:[2]int)->(l_pos:[2]int){
    n_pos:=t_pos
    if n_pos.x<0{
        n_pos.x+=1
        l_pos.x = (n_pos.x%tile_map_size) +tile_map_size-1
        l_pos.x = abs(l_pos.x)
    }else{
        l_pos.x = n_pos.x%tile_map_size
    }

    if n_pos.y<0{
        n_pos.y+=1
        l_pos.y = (n_pos.y%tile_map_size) +tile_map_size-1
        l_pos.y = abs(l_pos.y)
    }else{
        l_pos.y = n_pos.y%tile_map_size
    }

    return l_pos
}
t_pos_g_pos::proc(t_pos:[2]int)->(g_pos:[2]int){
    n_pos:=t_pos
    if n_pos.x<0{
        n_pos.x-=tile_map_size-1
        // g_pos.x = n_pos.x/tile_map_size
    }
    if n_pos.y<0{
        n_pos.y-=tile_map_size-1
        // g_pos.y = n_pos.y/tile_map_size
    }
    g_pos=n_pos/tile_map_size
    return g_pos
}
get_tile_l1::proc(t_pos:[2]int)->(tile:tile_set_names){
    l_pos:=t_pos_l_pos(t_pos)
    return g.st.game_map.tile_maps[t_pos_g_pos(t_pos)].data[l_pos.x][l_pos.y].l1
}
get_tile_l2::proc(t_pos:[2]int)->(tile:tile_set_names){
    l_pos:=t_pos_l_pos(t_pos)
    return g.st.game_map.tile_maps[t_pos_g_pos(t_pos)].data[l_pos.x][l_pos.y].l2
}

get_tile_building::proc(t_pos:[2]int)->(tile:^entity_index){
    l_pos:=t_pos_l_pos(t_pos)
    t_map:=&g.st.game_map.tile_maps[t_pos_g_pos(t_pos)] 
    data:= &t_map.data[l_pos.x][l_pos.y]
    return &data.building
}
// get_tile_img::proc(t_pos:[2]int)->(tile:^img_ani_name){
//     l_pos:=t_pos_l_pos(t_pos)
//     t_map:=&g.st.game_map.tile_maps[t_pos_g_pos(t_pos)] 
//     data:= &t_map.data[l_pos.x][l_pos.y]
//     return &data.l1
// }


// get_tile_building::proc(t_pos:[2]int)->(tile:^entity_index){
//     l_pos:=t_pos_l_pos(t_pos)
//     t_map:=&g.st.game_map.tile_maps[t_pos_g_pos(t_pos)]  
//     return &t_map.buildings[l_pos.x][l_pos.y]
// }
// get_tile_in_front::proc(t_pos:[2]int,rot:f32)->(tile:^tile_set_names){
//     n_pos:=t_pos
//     switch rot {
//         case 0:
//             n_pos.y-=1
//         case 90:
//             n_pos.x+=1
//         case 180:
//             n_pos.y+=1
//         case 270:
//             n_pos.x-=1
//     }
//     l_pos:=t_pos_l_pos(n_pos)
//     t_map:=&g.st.game_map.tile_maps[t_pos_g_pos(n_pos)]  
//     return &t_map.data[l_pos.x][l_pos.y].l1
// }
// get_building_in_front::proc(t_pos:[2]int,rot:f32,w_h:[2]int={1,1})->(tile:^entity_index){
//     n_pos:=t_pos
//     switch rot {
//         case 0:
//             n_pos.y-=1
//         case 90:
//             n_pos.x+=1+(w_h.x-1)
//         case 180:
//             n_pos.y+=1+(w_h.y-1)
//             n_pos.x+=(w_h.x-1)
//         case 270:
//             n_pos.x-=1+(w_h.y-1)
//     }
//     l_pos:=t_pos_l_pos(n_pos)
//     t_map:=&g.st.game_map.tile_maps[t_pos_g_pos(n_pos)]  
//     return &t_map.data[l_pos.x][l_pos.y].building
// }
// get_building_in_front::proc(entity:^entity,rot:f32=0,dist:int=1)->(tile:^entity_index){
//     n_pos:=world_pos_t_pos(entity.pos)
//     w_h:=entity.type.(building).w_h
//     true_rot:=entity.rot+rot
//     if true_rot <0 {true_rot = true_rot+360 }
//     if true_rot >270 {true_rot = true_rot-360 }
//     switch true_rot {
//         case 0:
//             n_pos.y-=dist
//         case 90:
//             n_pos.x+=dist+(w_h.x-1)
//         case 180:
//             n_pos.y+=dist+(w_h.y-1)
//             n_pos.x+=(w_h.x-1)
//         case 270:
//             n_pos.y-=-(w_h.y-1)
//             n_pos.x-=dist
//     }
//     l_pos:=t_pos_l_pos(n_pos)
//     t_map:=&g.st.game_map.tile_maps[t_pos_g_pos(n_pos)]  
//     return &t_map.data[l_pos.x][l_pos.y].building
// }

