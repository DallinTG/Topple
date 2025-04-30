#+feature dynamic-literals
package game
// import ecs "odin-ecs-main"
import "core:fmt"
import b2 "box2d"
import rl "vendor:raylib"
max_entities::8000


pos::struct{
    pos:[3]f32,
}
sprite::struct{
    image_id:img_ani_name,
    offset:[3]f32,
    origin:[2]f32,
    w_h:[2]f32,
}
entity_flags::enum{

}
entity_index::struct{
    id:u32,
    gen:u32,
}
entity_bucket::struct{
    entities:[max_entities]entity,
    next_open_slot:u32,
    last_entity:u32,
    count:u32,
}
entity_names::enum{
    bace,
    platform,
    b_block,
    L,

}
entity::struct{
    imag:img_ani_name,
    tint:rl.Color,
    body_id:b2.BodyId,
    last_frame_updated_on:i32,
    entity_index:entity_index,
    is_occupied:bool,
    name:entity_names,
    pos:[2]f32,
    rot:f32,
    callback_insert:proc(^entity),
    callback_replace:proc(^entity),
    callback_render:proc(^entity),
    logic:proc(^entity),
    init:proc(^entity),
    flags:bit_set[entity_flags],
    block_shape:[6][6]bool,
    w_h:[2]i32,
    init_data:^entity_init_data,
    score:i32,
    time:f32,
    is_inactiv:bool,
    in_danger_time:f32,

}
entity_init_data::struct{
    weight:i32,
    imag:img_ani_name,
    tint:rl.Color,
    body_def:b2.BodyDef,
    shape_def:b2.ShapeDef,
    size:[2]f32,
    is_block:bool,
    is_rand_block:bool,
    block_shape:[6][6]bool,
    shape_score:i32,
    type_score_m:i32,
    is_platform:bool,
    
}
entity_types::union{
}

block_shape::struct{
    block_shape:[6][6]bool,
    weight:i32,
    shape_score:i32,
}
block_shape_name::enum{
    L,
    J,
    T,
    U,
    X,
    S,
    Z,
    x1,
    x2,
    x3,
    x4,
    i4,
    i3,
    i2,
}
platform_shapes::enum{
    p1,
    p2,
    p3,
    p4,
    p5,
    p6,
    p7,
    p8,
}
block_names::enum{
    red,
    yellow,
    orange,
    green,
    blue,
    l_blue,
    purple,
}



init_defalt_items::proc(){
    g.defalt.items[.ore_copper] = {
        id = .ore_copper,
        // icon = .Round_Cat,
    }
}


init_defalt_entities::proc(){
    data:=&g.defalt.entities
    for name in entity_names{
        g.defalt.entities[name].name = name
        g.defalt.entities[name].tint = {255,255,255,255}
        g.defalt.entities[name].imag = .B_Block
    }

    data[.bace].imag=.B_Block

    data[.platform].imag=.B_Block
    
    data[.b_block].imag=.B_Block
    data[.b_block].logic = block_logic
    
    data[.L].imag=.B_Block
}
init_defalt_entities_init_data::proc(){
    data:=&g.defalt.ent_init_data
    for &data in &g.defalt.ent_init_data{
        data.body_def = b2.DefaultBodyDef()
        data.shape_def = b2.DefaultShapeDef()
    }
    data[.b_block].body_def.type = b2.BodyType.dynamicBody
    data[.b_block].body_def.position = {-100,-100}
    data[.b_block].size = {16,16}
    data[.b_block].is_block=false
    data[.b_block].is_rand_block = true


    data[.platform].body_def.type = b2.BodyType.staticBody
    data[.platform].body_def.position = {-100,-100}
    data[.platform].size = {16,16}
    data[.platform].is_block=true
    data[.platform].is_platform = true
    // data[.platform].is_rand_block = true

    data[.bace].body_def.type = b2.BodyType.dynamicBody
    data[.bace].body_def.position = {-100,-100}
    data[.bace].size = {16,16}
    data[.bace].is_block=true
    data[.bace].block_shape ={
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
    }
    data[.L].body_def.type = b2.BodyType.dynamicBody
    data[.L].body_def.position = {-100,-100}
    data[.L].size = {16,16}
    data[.L].is_block=true
    data[.L].block_shape ={
        {true,true,true,false,false,false},
        {true,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }

}



create_entity_by_id::proc(id:entity_names)->(entity_index:entity_index){
    return create_entity(g.defalt.entities[id])
    
}
create_entity_by_id_box2d::proc(id:entity_names,pos:[2]f32)->(entity_index:entity_index){
    d_data:=&g.defalt.ent_init_data[id]
    entity_index=create_entity(g.defalt.entities[id])
    ent:=get_entity_by_index(entity_index)    
    if d_data.is_rand_block{
        d_data=get_rand_block_data()
        ent.imag = d_data.imag
        ent.tint= d_data.tint
        ent.score=d_data.type_score_m
    }
    bodydef:=d_data.body_def
    bodydef.position = pos
    body_id:b2.BodyId = b2.CreateBody(g.box_2d_world_id, bodydef)
    b2.Body_SetUserData(body_id,cast(rawptr)ent)
    box:b2.Polygon  = b2.MakeBox(d_data.size.x/2, d_data.size.y/2)
    shapedef:b2.ShapeDef = d_data.shape_def
    block_shape:=d_data.block_shape
    shape:=get_rand_shape()
    b_size_ofset:f32=-3
    if d_data.is_platform {
        b_size_ofset=0
        shape = get_rand_shape_platform()
    }
    ent.block_shape = shape.block_shape
    ent.score *= shape.shape_score
    ent.init_data=d_data
    add_shapes_to_body_from_block_shape(d_data,entity_index,body_id,b_size_ofset)
    
    ent.body_id=body_id

    if d_data.is_block{
        ent.callback_render=render_ent_block
    }else{
        ent.callback_render=render_ent
    }
    return 
}
add_shapes_to_body_from_block_shape::proc(d_data:^entity_init_data,entity_index:entity_index,body_id:b2.BodyId,block_size_add:f32=-2.5){
    ent:=get_entity_by_index(entity_index) 
    box:b2.Polygon  = b2.MakeBox(d_data.size.x/2, d_data.size.y/2)
    shapedef:b2.ShapeDef = d_data.shape_def
    if d_data.is_block{
        max_x:i32
        max_y:i32
        for &row,y in &ent.block_shape{
            for block,x in row{
                if block{
                    if x > cast(int)max_x {max_x +=1}
                    if y > cast(int)max_y {max_y +=1}
                    // box = b2.MakeOffsetBox((d_data.size.x/2)-.25, (d_data.size.y/2)-.25,{d_data.size.x*cast(f32)x,d_data.size.y*cast(f32)y},0)
                    // shape_id:=b2.CreatePolygonShape(body_id, shapedef, box)
                    // b2.Shape_SetUserData(shape_id,cast(rawptr)cast(uintptr)entity_index.id)
                }
            }
        }

        for &row,y in &ent.block_shape{
            for block,x in row{
                if block{
                    // if x > cast(int)max_x {max_x +=1}
                    // if y > cast(int)max_y {max_y +=1}
                    box = b2.MakeOffsetBox((d_data.size.x/2)+block_size_add, (d_data.size.y/2)+block_size_add,{(d_data.size.x*cast(f32)x)-(cast(f32)max_x*cast(f32)block_size),(d_data.size.y*cast(f32)y)-(cast(f32)max_y*cast(f32)block_size)},0)
                    shape_id:=b2.CreatePolygonShape(body_id, shapedef, box)
                    b2.Shape_SetUserData(shape_id,cast(rawptr)cast(uintptr)entity_index.id)
                }
            }
        }
        max_x+=1
        max_y+=1
        ent.w_h = {max_x,max_y}
    }else{
        _=b2.CreatePolygonShape(body_id, shapedef, box)
    }
}
create_entity::proc(entity:entity)->(entity_id:entity_index){
    bucket :=&g.st.entity_bucket
    if bucket.next_open_slot == 0{
        bucket.next_open_slot = 1
        bucket.last_entity = 1
        bucket.count=0
    }
    next_slot:=&bucket.entities[bucket.next_open_slot]
    ent:=&bucket.entities
    if !next_slot.is_occupied{

        bucket.count +=1
        temp_gen:=next_slot.entity_index.gen
        next_slot^ = entity
        next_slot.is_occupied = true
        next_slot.entity_index.gen = temp_gen+1
        entity_id = {id = bucket.next_open_slot,gen = next_slot.entity_index.gen}
        next_slot.entity_index = entity_id
        if entity.init !=nil {
            entity.init(next_slot)
        }

        if bucket.next_open_slot != max_entities-1{
            bucket.next_open_slot += 1
            for bucket.entities[bucket.next_open_slot].is_occupied{
                if bucket.next_open_slot != max_entities-1{
                    bucket.next_open_slot += 1
                }else { break }
            }
        }

        if bucket.last_entity != max_entities-1 {
            for bucket.entities[bucket.last_entity].is_occupied{
                if bucket.last_entity != max_entities-1{
                    bucket.last_entity += 1
                }else{break}
            }
        }

        return entity_id
    }
    entity_id = {0,0}
    return entity_id
}

delete_entity::proc(entity_id:entity_index){
    bucket :=&g.st.entity_bucket
    if bucket.entities[entity_id.id].entity_index.gen == entity_id.gen && bucket.entities[entity_id.id].is_occupied{
        ent:=get_entity_by_index(entity_id)
        b2.DestroyBody(ent.body_id)
        bucket.count -=1
        bucket.entities[entity_id.id].is_occupied=false
        bucket.entities[bucket.next_open_slot].entity_index.gen += 1
        // if b2.Body_IsValid(bucket.entities[entity_id.id].entity.body_id){
        //     b2.DestroyBody(bucket.entities[entity_id.id].entity.body_id)
        // }
        
        if entity_id.id < bucket.next_open_slot{
            bucket.next_open_slot = entity_id.id 
        }
        if entity_id.id == bucket.last_entity {
            if bucket.last_entity != 0 {
                bucket.last_entity -= 1
                for !bucket.entities[bucket.last_entity].is_occupied{
                    bucket.last_entity -= 1
                }
            }
        }
    }
}
delete_all_entitys::proc(){
    entities :=&g.st.entity_bucket.entities
    if g.st.entity_bucket.count > 0 {
        for &entity,i in entities[:g.st.entity_bucket.last_entity+1]{
            if entity.is_occupied {
                b2.DestroyBody(entity.body_id)
            }
        }
    }
    g.entity_bucket = {}
}

dos_entity_exist::proc(entity_id:entity_index)->bool{
    
    bucket :=&g.st.entity_bucket
    if bucket.entities[entity_id.id].entity_index.gen == entity_id.gen&& bucket.entities[entity_id.id].is_occupied{
        return true
    }
    return false
}

get_entity_by_index::proc(entity_id:entity_index) -> (entity:^entity){
    bucket :=&g.st.entity_bucket
    if dos_entity_exist(entity_id) {
        entity = &bucket.entities[entity_id.id]
        return
    }
    entity = nil
    return
}

do_entities::proc(){
    
    entities :=&g.st.entity_bucket.entities
    if g.st.entity_bucket.count > 0 {
        for &entity,i in entities[:g.st.entity_bucket.last_entity+1]{
            if entity.is_occupied {
                entity.time += g.time.dt
                if entity.callback_replace!=nil{
                    entity.callback_replace(&entity)
                }else {
                    if entity.callback_insert!=nil{
                        entity.callback_insert(&entity)
                    }
                    if entity.logic!=nil{
                        if !entity.is_inactiv{
                            entity.logic(&entity)
                        }
                    }
                }
            }
        }
    }
}
draw_entities::proc(){
    entities :=&g.st.entity_bucket.entities
    if g.st.entity_bucket.count > 0 {
        for &entity,i in entities[:g.st.entity_bucket.last_entity+1]{
            if entity.is_occupied {
                if entity.callback_render!=nil{
                    entity.callback_render(&entity)
                }
            }
        }
    }
}

render_ent_block::proc(entity:^entity){
    d_data:=&g.defalt.ent_init_data[entity.name]
    // pos:=b2.Body_GetPosition(entity.body_id)
    pos:=b2.Body_GetWorldPoint(entity.body_id,{-d_data.size.x/2*cast(f32)entity.w_h.x,-d_data.size.y/2*cast(f32)entity.w_h.y})
    rot:=b2.Body_GetRotation(entity.body_id)

    x_origin_ofset:=cast(f32)(entity.w_h.x-1)*block_size/2
    y_origin_ofset:=cast(f32)(entity.w_h.y-1)*block_size/2
    for &row,y in &entity.block_shape{
        for block,x in row{
            if block{
                draw_image(
                    entity.imag,
                    {pos.x-.01,pos.y-.01,d_data.size.x+.02,d_data.size.y+.02},
                    0,
                    {-(cast(f32)x*(d_data.size.x)-x_origin_ofset),-(cast(f32)y*(d_data.size.y)-y_origin_ofset)},
                    b2.Rot_GetAngle(rot)*cast(f32)rl.RAD2DEG,
                    entity.tint

                )

                // rl.DrawCircleV(pos, 1.0, rl.BLACK)
                // pos = pos
                // rl.DrawCircleV(pos, 1.0, rl.BLUE)
                // pos = b2.Body_GetWorldPoint(entity.body_id, { -d_data.size.x/2, -d_data.size.y/2 })
                // rl.DrawCircleV(pos, 3.0, rl.RED)
            }
        }
    }
}

render_ent_block_pos_overide::proc(entity:^entity,pos:[2]f32){
    d_data:=&g.defalt.ent_init_data[entity.name]
    // pos:=b2.Body_GetPosition(entity.body_id)
    // pos:=b2.Body_GetWorldPoint(entity.body_id,{-d_data.size.x/2*cast(f32)entity.w_h.x,-d_data.size.y/2*cast(f32)entity.w_h.y})
    rot:=b2.Body_GetRotation(entity.body_id)

    x_origin_ofset:=cast(f32)(entity.w_h.x-1)*block_size/2
    y_origin_ofset:=cast(f32)(entity.w_h.y-1)*block_size/2
    for &row,y in &entity.block_shape{
        for block,x in row{
            if block{
                draw_image(
                    entity.imag,
                    {pos.x-.01,pos.y-.01,d_data.size.x+.02,d_data.size.y+.02},
                    0,
                    {-(cast(f32)x*(d_data.size.x)-x_origin_ofset),-(cast(f32)y*(d_data.size.y)-y_origin_ofset)},
                    b2.Rot_GetAngle(rot)*cast(f32)rl.RAD2DEG,
                    entity.tint

                )

                // rl.DrawCircleV(pos, 6.0, rl.BLACK)
                // pos := pos
                // rl.DrawCircleV(pos, 1.0, rl.BLUE)
                // pos = b2.Body_GetWorldPoint(entity.body_id, { -d_data.size.x/2, -d_data.size.y/2 })
                // rl.DrawCircleV(pos, 3.0, rl.RED)
            }
        }
    }
}

render_ent::proc(entity:^entity){
    d_data:=&g.defalt.ent_init_data[entity.name]
    pos:=b2.Body_GetWorldPoint(entity.body_id,{-d_data.size.x/2,-d_data.size.y/2})
    rot:=b2.Body_GetRotation(entity.body_id)
    draw_image(
        entity.imag,
        {pos.x,pos.y,d_data.size.x,d_data.size.y},
        0,
        {0,0},
        b2.Rot_GetAngle(rot)*cast(f32)rl.RAD2DEG,
        entity.tint,
    )

	// I used these circles to ensure the coordinates are correct
	// rl.DrawCircleV(pos, 1.0, rl.BLACK)
	// pos = b2.Body_GetPosition(entity.body_id)
	// rl.DrawCircleV(pos, 1.0, rl.BLUE)
	// pos = b2.Body_GetWorldPoint(entity.body_id, { -d_data.size.x/2, -d_data.size.y/2 })
	// rl.DrawCircleV(pos, 3.0, rl.RED)

}

