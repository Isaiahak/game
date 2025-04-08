package game

import rl "vendor:raylib"
import "core:math"
import "core:fmt"

WINDOW_SIZE :: 900
GRID_WIDTH :: 20
GRID_HEIGHT :: 16
CELL_SIZE :: 16
CANVAS_SIZE_WIDTH :: GRID_WIDTH*CELL_SIZE
CANVAS_SIZE_HEIGHT :: GRID_HEIGHT*CELL_SIZE
TICK_RATE :: 0.13
MOVE_DISTANCE :: 0.25*CELL_SIZE
FALL_DISTANCE :: 0.5*CELL_SIZE
MAX_ANGLE :: math.RAD_PER_DEG*80
MIN_ANGLE :: math.RAD_PER_DEG*20
Move_state :: enum {Falling,Standing,Against_Wall}

Character :: struct{
	pos: rl.Vector2,
	hp:  int,
	walk_distance: int,
	dir: int, // 1 == right 0 == left
	move_state: Move_state,
}

Projectile :: struct{
	pos: rl.Vector2,
	shoot_strength: f32,
	angle: f32, 
	velocity_vector: rl.Vector2,
	fire_time: f64,
}

Map : [GRID_WIDTH][GRID_WIDTH] bool = {
    {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false},
    {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false},
    {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false},
    {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false},
    {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false},
    {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false},
    {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false},
    {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false},
    {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false},
    {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false},
    {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false},
    {false,false,false,false,false,false,false,true,true,true,false,false,false,false,false,false,false,false,false,false},
    {false,false,false,false,false,false,false,true,true,true,false,false,false,false,false,false,false,false,false,false},
    {false,false,false,false,false,false,false,true,true,true,false,false,false,false,false,false,false,false,false,false},
    {true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true},
    {true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true},
    {true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true},
    {true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true},
    {true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true},
    {true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true}
};

Turn :: enum{Player,Enemy,Projectile}
Action :: enum{Move,Shoot}
Player_Projectiles : Projectile
Enemy_Projectiles : Projectile
tick_timer: f32 = TICK_RATE
move_direction: rl.Vector2
abs_move_direction: rl.Vector2 
player_dir: int
enemy_dir: int
player_pos: rl.Vector2 
player: Character
enemy: Character
player_move_state : Move_state
enemy_move_state : Move_state
enemy_pos: rl.Vector2
walk_distance:= 1000
current_turn: Turn
prev_turn: Turn
current_action: Action
timer: f64
start_time: f64
shoot_strength: f32 
round_time: f64
shoot_angle: f32
angle_change : f32
count_up: bool
reset : bool
step : int 


move_character :: proc(character: Character, cur_turn: Turn) -> (moved_character: Character){
	moved_character = character
	#partial switch cur_turn{
		case Turn.Player:
			if timer - start_time < round_time{ 
				if check_for_wall(moved_character.pos,moved_character.dir) || check_for_border(moved_character.pos){
					moved_character.move_state = Move_state.Against_Wall
				}
				if check_if_falling(moved_character.pos){
					moved_character.move_state = Move_state.Falling
				}
				else if check_if_standing(moved_character.pos){
					moved_character.move_state = Move_state.Standing
				}
				fmt.println(moved_character.move_state, moved_character.pos)
				switch moved_character.move_state{
					case Move_state.Falling: 
						moved_character.pos.y += FALL_DISTANCE
					case Move_state.Standing:
						if timer - start_time < round_time{
							if walk_distance - moved_character.walk_distance > 0{ 
								if rl.IsKeyDown(.RIGHT){
									moved_character.pos.x += MOVE_DISTANCE
									moved_character.dir = 1
								}else if rl.IsKeyDown(.LEFT){
									moved_character.pos.x -= MOVE_DISTANCE
									moved_character.dir = 0
								}
							}else{
								current_action = Action.Shoot
							}
						}else{
							prev_turn = current_turn
							current_turn = Turn.Projectile
						}
					case Move_state.Against_Wall: 
						if timer - start_time < round_time{
							if walk_distance - moved_character.walk_distance > 0{
								if rl.IsKeyDown(.RIGHT) && find_wall_and_border_side(moved_character.pos) == 0 && find_wall_and_border_side(moved_character.pos) != 1{
									moved_character.pos.x += MOVE_DISTANCE
									moved_character.dir = 1
								}else if rl.IsKeyDown(.LEFT) && find_wall_and_border_side(moved_character.pos) == 1 && find_wall_and_border_side(moved_character.pos) != 0 {
									moved_character.pos.x -= MOVE_DISTANCE
									moved_character.dir = 0
								}
							}else{
								current_action = Action.Shoot
							}
						}else{
							prev_turn = current_turn
							current_turn = Turn.Projectile
						}
				}
				if rl.IsKeyDown(.UP){

				}else if rl.IsKeyDown(.DOWN){

				}else if rl.IsKeyDown(.SPACE){
					current_action = Action.Shoot
				}
			}else{
				prev_turn = current_turn
				current_turn = Turn.Projectile
			}


		case Turn.Enemy: 
		}
	return moved_character
	}



check_if_standing :: proc(player_pos: rl.Vector2) -> bool{
	if Map[int(player_pos.y/CELL_SIZE)][int(player_pos.x/CELL_SIZE)] == true{
		return true
	}else{
		return false
	}
}

check_if_falling :: proc(player_pos: rl.Vector2) -> bool{
	if Map[int((player_pos.y)/CELL_SIZE)][int(player_pos.x/CELL_SIZE)] == false{
		return true
	}else{
		return false
	}
}

check_for_wall :: proc(player_pos: rl.Vector2, dir: int) -> bool{
	result : bool
	fmt.println(Map[int(player_pos.y/CELL_SIZE)][int((player_pos.x + 1)/CELL_SIZE)])
	fmt.println(Map[int(player_pos.y/CELL_SIZE)][int((player_pos.x - 1)/CELL_SIZE)])
	if dir == 1 {
		if Map[int(player_pos.y/CELL_SIZE)][int((player_pos.x + 1)/CELL_SIZE)] == true{
			result = true
		}
	}if dir == 0 {
		if Map[int(player_pos.y/CELL_SIZE)][int((player_pos.x - 1)/CELL_SIZE)] == true{
			result = true
		}
	}else{
		result = false
	}
	return result
}

check_for_border :: proc(player_pos: rl.Vector2) -> bool{
	fmt.println(GRID_WIDTH*CELL_SIZE)
	if player_pos.y > GRID_HEIGHT*CELL_SIZE{
		return true
	}else if player_pos.x <= 0{
		return true
	}
	else if player_pos.x > GRID_WIDTH*CELL_SIZE-MOVE_DISTANCE{
		return true
	}else{
		return false
	}	
}

move_projectile :: proc(projectile_pos :rl.Vector2, projectile_time :f64) -> (new_pos :rl.Vector2){
	new_pos = projectile_pos
	delta_t := rl.GetTime() - projectile_time
	gravity : f64 = -1
	initial_pos := player.pos
	new_pos.x = f32(f64(initial_pos.x) + f64(Player_Projectiles.velocity_vector[0])*delta_t)
	new_pos.y = f32(f64(initial_pos.y) + f64(Player_Projectiles.velocity_vector[1])*delta_t + 1/2 * gravity * delta_t * delta_t)
	return new_pos

}

find_wall_and_border_side :: proc (player_pos: rl.Vector2) -> int{
	side := 2
	//left side
	if player_pos.x - MOVE_DISTANCE<= 0 || Map[int((player_pos.x - 1)/CELL_SIZE)][int(player_pos.y/CELL_SIZE)] == true{
		side = 0
	}
	else if player_pos.x + MOVE_DISTANCE >= GRID_WIDTH*CELL_SIZE || Map[int((player_pos.x + 1)/CELL_SIZE)][int(player_pos.y/CELL_SIZE)] == true{
	//right side
		side = 1
	}
	fmt.print(side)
	return side
}

change_angle :: proc(curr_angle, angle_change:f32, direction:int) -> f32{
	new_angle := curr_angle
	if direction == 1{
		if curr_angle < MAX_ANGLE {
			new_angle = curr_angle + angle_change 
		}
	}
	else{
		if curr_angle > MIN_ANGLE {	
			new_angle = curr_angle - angle_change 
		}
	}
	return new_angle
} 

refresh :: proc(){
	player_pos= {0,13}
	player_move_state = Move_state.Standing
	player = {player_pos,100,0,player_dir,player_move_state}
	enemy_pos = {18,13}
	enemy_move_state = Move_state.Standing
	enemy = {enemy_pos,3,100,enemy_dir,enemy_move_state}
	angle_change = math.RAD_PER_DEG
	round_time = 30
	shoot_angle = math.RAD_PER_DEG*45
	current_turn = Turn.Player
	prev_turn = Turn.Player
	current_action = Action.Move
	start_time = rl.GetTime()
	count_up = true
	reset = false
}

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_SIZE,WINDOW_SIZE, "game")
	//sprite declaration
	knight_sprite := rl.LoadTexture("Images/knight.png")
	knight_sprite.width = CELL_SIZE
	knight_sprite.height = CELL_SIZE
	enemy_sprite := rl.LoadTexture("Images/enemy.png")
	enemy_sprite.width = CELL_SIZE
	enemy_sprite.height = CELL_SIZE
	dirt_texture := rl.LoadTexture("Images/dirt.png")
	sky_texture := rl.LoadTexture("Images/background.png")
	bullet := rl.LoadTexture("Images/fire_balls.png")

	refresh()
	
	for !rl.WindowShouldClose(){
		tick_timer = tick_timer - rl.GetFrameTime()
		//fmt.println(player.abs.x, player.abs.y, ", relative pos: ", player.pos.x*CELL_SIZE,player.pos.y*CELL_SIZE,"steps",player.walk_distance,"direction",player.dir_x)
		timer = rl.GetTime()
		move_direction = {0,0}
		abs_move_direction = {0,0}
		step = 0
		//game clock logic
		if tick_timer <= 0 {
			if rl.IsKeyDown(.F){
				refresh()
			}
			switch current_turn{
				case .Player:
					switch current_action{
						case .Move:
							player = move_character(player,current_turn)
						case .Shoot:
							break	
							
					}
						 
				case .Enemy:
					switch current_action{
						case .Move: 
							player = move_character(enemy,current_turn)
						case .Shoot: 
							break
							

					}
				case .Projectile:
				// the projectile needs to fly enemy or and play and once its done we go to the next state
				#partial switch prev_turn{
					case .Player: 
						Player_Projectiles.pos = move_projectile(Player_Projectiles.pos, Player_Projectiles.fire_time)
						for i in 0..<GRID_WIDTH{
							for j in 0..<GRID_WIDTH{
								if Map[j][i] == true{
									if rl.CheckCollisionPointRec(Player_Projectiles.pos, rl.Rectangle{f32(i),f32(j),GRID_WIDTH,GRID_WIDTH}){
										prev_turn := Turn.Player
										current_turn := Turn.Enemy
										start_time = rl.GetTime()
										shoot_angle = math.PI / 4

									}
								}
							}
						}
						if rl.CheckCollisionPointRec(Player_Projectiles.pos, rl.Rectangle{enemy.pos.x,enemy.pos.y,GRID_WIDTH,GRID_WIDTH}){
							enemy.hp = enemy.hp - 1
							prev_turn := Turn.Player
							current_turn := Turn.Enemy
							start_time = rl.GetTime()
							shoot_angle = math.PI / 4
						}
						
					case .Enemy: 
						// enemy projectile logic
						if rl.IsKeyDown(.N) {
							// figure out shoot logic
							prev_turn = Turn.Enemy
							current_turn = Turn.Player
							current_action = Action.Move
							start_time = rl.GetTime()
							shoot_angle = math.PI / 4
						}	
				}
			}
			tick_timer += TICK_RATE
		}
		

		// display drawing
		rl.BeginDrawing()
		camera := rl.Camera2D {
			zoom = f32(WINDOW_SIZE/ CANVAS_SIZE_HEIGHT)
		}
		rl.BeginMode2D(camera)
		rl.DrawTextureV(enemy_sprite,{f32(enemy.pos.x),f32(enemy.pos.y)}*CELL_SIZE,rl.WHITE)
		for i in 0..<GRID_WIDTH{
			for j in 0..<GRID_WIDTH{
				if Map[i][j] == true {
					source := rl.Rectangle{0,0,f32(dirt_texture.width),f32(dirt_texture.height),}
					destination := rl.Rectangle {f32(j)*CELL_SIZE,f32(i)*CELL_SIZE,CELL_SIZE,CELL_SIZE,}
					rl.DrawTexturePro(dirt_texture,source,destination,{CELL_SIZE,CELL_SIZE}*0.5,0,rl.WHITE)
				}else{
					source := rl.Rectangle{0,0,f32(sky_texture.width),f32(sky_texture.height),}
					destination := rl.Rectangle {f32(j)*CELL_SIZE,f32(i)*CELL_SIZE,CELL_SIZE,CELL_SIZE,}
					rl.DrawTexturePro(sky_texture,source,destination,{CELL_SIZE,CELL_SIZE}*0.5,0,rl.WHITE)
				}
			}
		}


		source_player := rl.Rectangle{0,0,f32(knight_sprite.width),f32(knight_sprite.height),}
		destination_player := rl.Rectangle {f32(player.pos.x),f32(player.pos.y),CELL_SIZE*2,CELL_SIZE*2,}
		rl.DrawTexturePro(knight_sprite,source_player,destination_player,{CELL_SIZE*0.5,CELL_SIZE},0,rl.WHITE)
		source_bullet := rl.Rectangle{0,0,f32(16),f32(16),}
		destination_bullet := rl.Rectangle {f32(Player_Projectiles.pos.x)*CELL_SIZE,f32(Player_Projectiles.pos.y)*CELL_SIZE,CELL_SIZE/2,CELL_SIZE/2,}
		rl.DrawTexturePro(bullet,source_bullet,destination_bullet,{CELL_SIZE,CELL_SIZE}*0.5,0,rl.WHITE)
		time_remaining := int(start_time - timer + f64(30))
		
		if current_turn != Turn.Projectile {
			time_remaining_str := fmt.ctprintf("Time remaining: %v",time_remaining)
			rl.DrawText(time_remaining_str,CANVAS_SIZE_WIDTH/2,GRID_WIDTH/2,10,rl.GRAY)
		}
		current_turn_str := fmt.ctprintf("Current Turn: %v", current_turn)
		rl.DrawText(current_turn_str,CANVAS_SIZE_WIDTH/2 - CELL_SIZE, GRID_WIDTH,8,rl.GRAY)
		enemy_hp_str := fmt.ctprintf("BOSS HEALTH: %v / 3", enemy.hp)
		rl.DrawText(enemy_hp_str,CANVAS_SIZE_WIDTH/2,1,10,rl.RED)
		current_angle_str := fmt.ctprintf("Current Angle %v", shoot_angle*math.DEG_PER_RAD)
		rl.DrawText(current_angle_str,4,CANVAS_SIZE_HEIGHT,8,rl.BLACK)
		current_strength_str := fmt.ctprintf("Current Shoot Strength %v", shoot_strength)
		rl.DrawText(current_strength_str,4,CANVAS_SIZE_HEIGHT - GRID_HEIGHT,8,rl.BLACK)
		steps_remaining_str := fmt.ctprintf("Steps Remaining: %v", walk_distance - player.walk_distance)
		rl.DrawText(steps_remaining_str,CANVAS_SIZE_WIDTH-GRID_WIDTH*6.5,CANVAS_SIZE_HEIGHT,8,rl.BLACK)

		shoot_vector := rl.Vector2 {(math.cos(shoot_angle) + CELL_SIZE), (math.sin(shoot_angle) + CELL_SIZE)}
		rl.DrawLine( i32(shoot_vector.x), i32(shoot_vector.y),i32(player.pos.x*CELL_SIZE), i32(player.pos.y*CELL_SIZE),rl.BLACK)
		
		free_all(context.temp_allocator)
		rl.EndMode2D()
		rl.EndDrawing()
	}
	rl.UnloadTexture(knight_sprite)
	rl.UnloadTexture(enemy_sprite)
	rl.UnloadTexture(dirt_texture)
	rl.UnloadTexture(sky_texture)
	rl.UnloadTexture(bullet)
	rl.CloseWindow()
}