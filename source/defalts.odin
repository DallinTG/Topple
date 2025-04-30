package game

import "core:fmt"
import "core:math"
import "core:math/rand"
import b2 "box2d"

defalt::struct{
    items:[item_names]item,
    entities:[entity_names]entity,
    ent_init_data:[entity_names]entity_init_data,
    block_shapes:[block_shape_name]block_shape,
    weighted_shapes:[dynamic]block_shape,
    platform_shapes:[platform_shapes]block_shape,
    weighted_platform_shapes:[dynamic]block_shape,
    block_data:[block_names]entity_init_data,
    weighted_block_data:[dynamic]block_names,
}

init_defalts::proc(){
    init_defalt_items()

    init_defalt_entities()
    init_defalt_entities_init_data()
    init_defalt_block_shapes()
    init_defalt_block_data()
    init_defalt_block_shapes_weight()
    init_defalt_block_data_weight()
    init_defalt_platform_shapes()
    init_defalt_platform_shapes_weight()
    init_cloudes()
}

init_defalt_block_data::proc(){
    blocks:=&g.defalt.block_data
    for &block in blocks{
        block.weight = 100
        block.imag=.B_Block
        block.tint={255,255,255,255}
        block.body_def = b2.DefaultBodyDef()
        block.shape_def = b2.DefaultShapeDef()
        block.is_block = true
        block.is_rand_block = true
        block.body_def.type = b2.BodyType.dynamicBody
        block.body_def.position = {-100,-100}
        block.size = {block_size,block_size}
        block.type_score_m = 1
    }
    blocks[.blue].weight = 100
    blocks[.blue].tint = {20,33,219,255}
    blocks[.blue].type_score_m = 1

    blocks[.l_blue].weight = 100
    blocks[.l_blue].tint = {13,162,212,255}
    blocks[.l_blue].type_score_m = 1

    blocks[.green].weight = 100
    blocks[.green].tint = {14,199,26,255}
    blocks[.green].type_score_m = 1

    blocks[.orange].weight = 100
    blocks[.orange].tint = {219,115,11,255}
    blocks[.orange].type_score_m = 1

    blocks[.purple].weight = 100
    blocks[.purple].tint = {130,13,214,255}
    blocks[.purple].type_score_m = 1

    blocks[.red].weight = 100
    blocks[.red].tint = {217,33,13,255}
    blocks[.red].type_score_m = 1

    blocks[.yellow].weight = 100
    blocks[.yellow].tint = {247,235,5,255}
    blocks[.yellow].type_score_m = 1

}
init_defalt_platform_shapes::proc(){
    data:=&g.defalt.platform_shapes
    for &shape in data{
        shape.weight = 100
        shape.block_shape={
            {true,true,true,true,true,true},
            {true,true,true,true,true,true},
            {true,true,true,true,true,true},
            {false,false,false,false,false,false},
            {false,false,false,false,false,false},
            {false,false,false,false,false,false},
        }
        shape.shape_score = 10
    }
    data[.p1].weight = 100
    data[.p1].shape_score = 20
    data[.p1].block_shape ={
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
    }
    data[.p2].weight = 100
    data[.p2].shape_score = 20
    data[.p2].block_shape ={
        {false,false,false,false,false,false},
        {true,false,true,false,true,true},
        {true,true,true,false,true,true},
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
    }
    data[.p3].weight = 100
    data[.p3].shape_score = 20
    data[.p3].block_shape ={
        {true,true,false,true,false,true},
        {false,true,true,true,true,true},
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
        {true,true,true,true,true,true},
        {false,false,false,false,false,false},
    }
    data[.p4].weight = 100
    data[.p4].shape_score = 20
    data[.p4].block_shape ={
        {false,true,false,true,false,true},
        {true,true,true,true,true,true},
        {true,true,true,true,true,false},
        {false,true,true,true,true,true},
        {true,true,true,true,true,false},
        {true,false,true,false,true,true},
    }
    data[.p5].weight = 100
    data[.p5].shape_score = 20
    data[.p5].block_shape ={
        {false,true,false,false,true,false},
        {false,true,false,false,true,true},
        {true,true,false,true,true,true},
        {false,true,true,true,true,true},
        {false,true,true,true,true,true},
        {true,true,true,true,true,true},
    }
    data[.p6].weight = 100
    data[.p6].shape_score = 20
    data[.p6].block_shape ={
        {false,false,false,false,true,false},
        {false,false,false,true,true,false},
        {false,false,true,true,true,true},
        {false,false,true,true,true,true},
        {false,false,true,true,true,true},
        {true,true,true,true,true,true},
    }
    data[.p7].weight = 100
    data[.p7].shape_score = 20
    data[.p7].block_shape ={
        {false,false,false,false,false,false},
        {true,false,true,false,true,false},
        {true,true,true,true,true,true},
        {true,true,true,true,true,false},
        {true,true,true,true,true,true},
        {false,false,false,false,false,false},
    }
    data[.p8].weight = 100
    data[.p8].shape_score = 20
    data[.p8].block_shape ={
        {false,false,false,false,false,false},
        {true,true,true,false,true,false},
        {false,true,true,true,true,true},
        {false,true,true,true,true,false},
        {true,true,true,true,true,true},
        {false,false,false,false,false,false},
    }
}

init_defalt_block_shapes::proc(){
    data:=&g.defalt.block_shapes
    for &shape in data{
        shape.weight = 100
        shape.block_shape={
            {true,false,false,false,false,false},
            {false,false,false,false,false,false},
            {false,false,false,false,false,false},
            {false,false,false,false,false,false},
            {false,false,false,false,false,false},
            {false,false,false,false,false,false},
        }
        shape.shape_score = 10
    }
    data[.L].weight = 100
    data[.L].shape_score = 20
    data[.L].block_shape ={
        {true,true,true,false,false,false},
        {true,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }
    data[.J].weight = 100
    data[.J].shape_score = 20
    data[.J].block_shape ={
        {true,false,false,false,false,false},
        {true,true,true,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }
    data[.T].weight = 100
    data[.T].shape_score = 25
    data[.T].block_shape ={
        {false,true,false,false,false,false},
        {true,true,true,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }
    data[.U].weight = 50
    data[.U].shape_score = 40
    data[.U].block_shape ={
        {true,false,true,false,false,false},
        {true,true,true,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }
    data[.X].weight = 50
    data[.X].shape_score = 50
    data[.X].block_shape ={
        {false,true,false,false,false,false},
        {true,true,true,false,false,false},
        {false,true,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }
    data[.S].weight = 100
    data[.S].shape_score = 30
    data[.S].block_shape ={
        {false,true,true,false,false,false},
        {true,true,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }
    data[.Z].weight = 100
    data[.Z].shape_score = 30
    data[.Z].block_shape ={
        {true,true,false,false,false,false},
        {false,true,true,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }
    data[.x1].weight = 100
    data[.x1].shape_score = 5
    data[.x1].block_shape ={
        {true,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }
    data[.x2].weight = 100
    data[.x2].shape_score = 20
    data[.x2].block_shape ={
        {true,true,false,false,false,false},
        {true,true,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }
    data[.x3].weight = 50
    data[.x3].shape_score = 45
    data[.x3].block_shape ={
        {true,true,true,false,false,false},
        {true,true,true,false,false,false},
        {true,true,true,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }
    data[.x4].weight = 10
    data[.x4].shape_score = 70
    data[.x4].block_shape ={
        {true,true,true,true,false,false},
        {true,true,true,true,false,false},
        {true,true,true,true,false,false},
        {true,true,true,true,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }
    data[.i4].weight = 100
    data[.i4].shape_score = 30
    data[.i4].block_shape ={
        {true,true,true,true,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }
    data[.i3].weight = 75
    data[.i3].shape_score = 20
    data[.i3].block_shape ={
        {true,true,true,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }
    data[.i2].weight = 100
    data[.i2].shape_score = 10
    data[.i2].block_shape ={
        {true,true,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
        {false,false,false,false,false,false},
    }

}
init_defalt_platform_shapes_weight::proc(){
    data:=&g.defalt.platform_shapes
    for &shape in data{
        for i in 0..<shape.weight {
            append(&g.defalt.weighted_platform_shapes, shape)
        }
    }
}

init_defalt_block_shapes_weight::proc(){
    data:=&g.defalt.block_shapes
    for &shape in data{
        for i in 0..<shape.weight {
            append(&g.defalt.weighted_shapes, shape)
        }
    }
}
get_rand_shape::proc()->block_shape{
    return rand.choice(g.defalt.weighted_shapes[:])
}
get_rand_shape_platform::proc()->block_shape{
    return rand.choice(g.defalt.weighted_platform_shapes[:])
}

init_defalt_block_data_weight::proc(){
    data:=&g.defalt.block_data
    for name in block_names{
        for i in 0..<data[name].weight {
            append(&g.defalt.weighted_block_data, name)
        }
    }
}
get_rand_block_data::proc()->^entity_init_data{
    return &g.defalt.block_data[rand.choice(g.defalt.weighted_block_data[:])]
}


init_cloudes::proc(){
    cl_imgs:=[?]img_ani_name {.Cloud_1,.Cloud_2,.Cloud_3,.Cloud_4}
    for &cloud in &g.cloudes{ 
        cloud.imag=rand.choice(cl_imgs[:])
        cloud.pos={(rand.float32()-.5)*7000,(rand.float32())*-10000}
        cloud.speed =(rand.float32()+.5)*12
        cloud.tint={255,255,255,cast(u8)(255*rand.float32())}
    }
}