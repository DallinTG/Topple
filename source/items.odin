package game

import rl"vendor:raylib"
import "core:fmt"

item_names::enum{
    None,
    sand,
    ore_copper,
    ore_iron,
    ore_stone,
    ore_coal,
    copper_ingot,
    iron_ingot,
    stone_ingot,
    steel_ingot,
    glass,
    core_frag,
}
item_tags::enum{
    is_resource,
    ore,
    ingot,
    copper,
    iron,
    stone,
    steel,
    sand,
    coal,
    fuel,
    r_in_foundry,
    glass,
}

item::struct{
    id:item_names,
    icon:img_ani_name,
    tint:rl.Color,
    tags:bit_set[item_tags],
}
item_slot::struct{
    item:item_names,
    count:i32,
    max_count:i32,
    required_tag:bit_set[item_tags],
}







