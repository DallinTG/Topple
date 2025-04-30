package game

import "core:fmt"
import "core:math/linalg"
import "core:math"
import "core:math/rand"
import "base:runtime"
import rl "vendor:raylib"
import noise"core:math/noise"
import clay "/clay-odin"
import "core:log"



init::proc(){
	rl.InitAudioDevice()
	init_clay_ui()
	init_seeds()
	init_sounds()
	init_shaders()
	init_atlases()
	init_box_2d()
	init_global_animations()
	init_defalts()
	init_defalt_settings()

	g.cam.position = {0,2,-100}
	g.cam.target = {0,2,0}
	g.cam.fovy = 720
	g.cam.projection=.ORTHOGRAPHIC
	g.cam.up = {0,-1,0}
	rand.reset(rand.uint64()+cast(u64)(rl.GetTime()*100000000000))

	// context.random_generator = runtime.Random_Generator
	

	// rl.SetMusicVolume(g.as.music , .10)   
	// rl.PlayMusicStream(g.as.music) 
	// create_entity_by_id_box2d(.bace,{0,-300})
	

	restart_game()
}

update :: proc() {
	mantine_timers()
	update_global_animations()
	calc_particles()
	sim_box_2d()
	do_entities()
	do_inputs()
	manage_sound_bytes()
	update_song()
	update_clay_ui()
	do_gamestate()

	
}

draw :: proc() {
	

	rl.BeginDrawing()
	rl.ClearBackground(rl.ColorLerp({114, 192, 237,255},{0,0,15,255},g.cam.position.y/5000*-1))
	rl.BeginMode3D(g.cam)
	rl.BeginShaderMode(g.as.shaders.bace)

	draw_background()
	// draw_game_map()
	draw_entities()
	draw_particles()
	draw_block_gyde_guidelines()
	draw_health()
	draw_puzle_mode_stuff()
	draw_title_screane()
	rl.EndShaderMode()
	rl.EndMode3D()

	rl.BeginMode2D(ui_camera())
	clayRaylibRender(&ui_render_command)
	rl.EndMode2D()
	// rl.DrawFPS(10,10)
	rl.EndDrawing()
}

ui_camera :: proc() -> rl.Camera2D {
	return {
		// zoom = f32(rl.GetScreenHeight())/PIXEL_WINDOW_HEIGHT,
		zoom = 1
	}
}
