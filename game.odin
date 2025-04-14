package game

import rl "vendor:raylib"
import "core:math"
import "core:fmt"

WINDOW_SIZE :: 640
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
TICK_RATE :: 0.13
MOVE_DISTANCE :: CELL_SIZE*2
FALL_DISTANCE :: CELL_SIZE*2
MAX_ANGLE :: math.RAD_PER_DEG*85
MIN_ANGLE :: math.RAD_PER_DEG*20
LEFT_MAX_ANGLE :: math.PI - math.RAD_PER_DEG*20
LEFT_MIN_ANGLE :: math.PI - math.RAD_PER_DEG*80
MAX_STRENGTH :: 21
MIN_STRENGTH :: 0
ANGLE_CHANGE :: 0.2
STRENGTH_CHANGE :: 1000
GRAVITY :: 0.020
Projectile_state :: enum {Stuck,Travelling}
Turn :: enum{Player,Enemy}
Action :: enum{Move,Aim,Fire}
Direction :: enum {Left,Right}
Projectile_type :: enum {Bullet,Fly}
Game_state :: enum{MainPage,LevelSelector,Combat,Victory,Defeat}
Level :: enum {Level1,Level2,Level3,Level4,Level5}
Character :: struct{
	pos: rl.Vector2,
	hp:  f32,
	walk_distance: int,
	dir: Direction, // 1 == right 0 == left
}

Player_Projectile :: struct{
	pos: rl.Vector2,
	strength: f32,
	angle: f32, 
	dir: Direction,
	state: Projectile_state,
	time: f32,
	type: Projectile_type,
}



Player_proj: Player_Projectile
tick_timer: f32 = TICK_RATE
move_direction: Direction
move_amount: f32

player_dir: Direction
player_pos: rl.Vector2 
player: Character

level1_enemy_dir: Direction
level1_enemy_pos: rl.Vector2 
level1_enemy: Enemy
level1_attack: Projectile

level2_enemy_dir: Direction
level2_enemy_pos: rl.Vector2 
level2_enemy: Gun_Enemy

level3_enemy_dir: Direction
level3_enemy_pos: rl.Vector2 
level3_enemy: Lazer_Enemy

level4_enemy_dir: Direction
level4_enemy_pos: rl.Vector2 
level4_enemy: Bomb_Enemy

level5_enemy_dir: Direction
level5_enemy_pos: rl.Vector2 
level5_enemy: Melee_Enemy

current_max_angle: f32
current_min_angle: f32
walk_distance:= 1000
current_turn: Turn
prev_turn: Turn
current_action: Action
timer: f64
start_time: f64
strength: f32 
round_time: f64
count_up: bool
reset : bool
up_key: rl.KeyboardKey
down_key: rl.KeyboardKey
current_game_state: Game_state
game_level: Level
current_map : [GRID_WIDTH][GRID_WIDTH] bool

MovePlayer :: proc(){
	if player.pos.x >= 0 && player.pos.x <= GRID_WIDTH*CELL_SIZE && player.pos.y >= 0 && player.pos.y <= GRID_WIDTH*CELL_SIZE{
		time := rl.GetFrameTime()
		if !IsStanding(player.pos){
			player.pos.y += FALL_DISTANCE * time
		}else{
			if rl.IsKeyDown(.RIGHT){
				player.dir = Direction.Right
				if !IsStuck(player.pos,player.dir){
					if MOVE_DISTANCE * time + player.pos.x > GRID_WIDTH*CELL_SIZE{
						overshoot := (MOVE_DISTANCE * time) + player.pos.x - GRID_WIDTH*CELL_SIZE
						move_amount = MOVE_DISTANCE * time - overshoot
					}else{
						move_amount = MOVE_DISTANCE * time
					}
				}
			}
			else if rl.IsKeyDown(.LEFT){
				player.dir = Direction.Left
				if !IsStuck(player.pos,player.dir){
					if  player.pos.x - (MOVE_DISTANCE * time) < 0{
						overshoot :=  player.pos.x - (MOVE_DISTANCE * time)  
						move_amount = - MOVE_DISTANCE * time + overshoot
					}else{
						move_amount = - MOVE_DISTANCE * time
					}
				}		
			}
			player.pos.x += move_amount
		}
	}
}

AimPlayerProjectile :: proc(projectile: Player_Projectile)->Player_Projectile{
	projectile := projectile
	time : f32
	if rl.IsKeyDown(.SPACE){
		time := rl.GetFrameTime() / 100
		if projectile.strength >= MIN_STRENGTH && projectile.strength <= MAX_STRENGTH{
			if projectile.strength < MAX_STRENGTH && count_up == true{
				if projectile.strength + (STRENGTH_CHANGE * time) > MAX_STRENGTH{
					overshoot_strength := projectile.strength + (STRENGTH_CHANGE * time) - MAX_STRENGTH
					projectile.strength = projectile.strength + (STRENGTH_CHANGE * time) - overshoot_strength
				}else{
					projectile.strength = projectile.strength + (STRENGTH_CHANGE * time)
				}
				if projectile.strength == MAX_STRENGTH{
					count_up = false
				}	
			}else{
				if projectile.strength - (STRENGTH_CHANGE * time) < MIN_STRENGTH{
					overshoot_strength := projectile.strength - (STRENGTH_CHANGE * time)
					projectile.strength = projectile.strength - (STRENGTH_CHANGE * time) + overshoot_strength
				}else{
					projectile.strength = projectile.strength - STRENGTH_CHANGE * time
				}
				if projectile.strength <= MIN_STRENGTH + 0.1{
					count_up = true
				}
			}
		}
	}
	else{	
		time = rl.GetFrameTime()
		if projectile.angle >= current_min_angle && projectile.angle <= current_max_angle {
			if rl.IsKeyDown(up_key){
				if (projectile.angle + (ANGLE_CHANGE * time)) > current_max_angle{
					angle_overshoot := projectile.angle + ( ANGLE_CHANGE * time) - current_max_angle
					projectile.angle = projectile.angle + (ANGLE_CHANGE *  time) - angle_overshoot
				}else{
					projectile.angle = projectile.angle + (ANGLE_CHANGE *  time)
				}
			}else if rl.IsKeyDown(down_key){
				if (projectile.angle - (ANGLE_CHANGE * time)) < current_min_angle{
					angle_overshoot := projectile.angle - (ANGLE_CHANGE * time) - current_min_angle 
					projectile.angle = projectile.angle - (ANGLE_CHANGE * time) - angle_overshoot		
				}else{
					projectile.angle = projectile.angle - (ANGLE_CHANGE * time) 
				}	
			}
		}
	}
	return projectile
}

MoveProjectile :: proc(projectile: Player_Projectile)->Player_Projectile{
	projectile := projectile
	time := rl.GetFrameTime()
	if BorderHit(projectile){
		if projectile.pos.x <= 0 || projectile.pos.x >= GRID_WIDTH*CELL_SIZE{
			if projectile.pos.x <= 0{
				projectile.pos.x = GRID_WIDTH*CELL_SIZE - CELL_SIZE
			}else{
				projectile.pos.x = 0.1
			}
		}else if projectile.pos.y == 0 || projectile.pos.y == GRID_WIDTH*CELL_SIZE{
			if projectile.pos.y == GRID_WIDTH {
				projectile.state = .Stuck
			}
		}
	}else if !WallHit(projectile){
		projectile.pos.x += (projectile.strength*math.cos(projectile.angle)*time)*CELL_SIZE
		projectile.time += time
		projectile.pos.y = projectile.pos.y - (projectile.strength*math.sin(projectile.angle)*time)*CELL_SIZE + GRAVITY*projectile.time
	}else{
		// figure out why it aint moving
		projectile.state = .Stuck
		if projectile.type == Projectile_type.Fly{
			player.pos.x = projectile.pos.x - CELL_SIZE + 0.1
			player.pos.y = projectile.pos.y - CELL_SIZE + 0.1
		}
		current_turn = .Enemy
		current_action = .Move
	}
	return projectile
}

IsStanding :: proc(player_pos: rl.Vector2) -> bool{
	result:= false
	if current_map[int((player_pos.y+CELL_SIZE)/CELL_SIZE)][int((player_pos.x)/CELL_SIZE)]{
		result = true
	}
	return result
}

IsStuck :: proc(player_pos:rl.Vector2, player_dir: Direction) -> bool{
	result := false
	if player_pos.y < 0 {
		result = true
	}
	if player_pos.y > GRID_WIDTH*CELL_SIZE {
		result = true
	}
	else if player_dir == Direction.Right{
		// if moving to the right
		if player_pos.x + CELL_SIZE > GRID_WIDTH*CELL_SIZE{
			result = true
		}
		else if current_map[int((player_pos.y)/CELL_SIZE)][int((player_pos.x+CELL_SIZE)/CELL_SIZE)]{
			result = true
		}
	}
	else if player_dir == Direction.Left{
		// if moving to the left
		if  player_pos.x < 0.01 {
			result = true
		}
		else if current_map[int((player_pos.y)/CELL_SIZE)][int((player_pos.x-CELL_SIZE)/CELL_SIZE)]{
			result = true
		}
		
	}
	return result		
}

WallHit :: proc(proj: Player_Projectile)-> bool{
	result : bool
	if proj.pos.x >= 0 && proj.pos.x <= GRID_WIDTH*CELL_SIZE && proj.pos.y >= 0 && proj.pos.y <= GRID_WIDTH*CELL_SIZE{
		if proj.dir == Direction.Right{
			if current_map[int(proj.pos.y/CELL_SIZE)][int((proj.pos.x)/CELL_SIZE)]{
				result = true
			}
		}else{
			if current_map[int(proj.pos.y/CELL_SIZE)][int((proj.pos.x-CELL_SIZE)/CELL_SIZE)]{
				result = true
			}
		}
	}else{
		result = false
	}
	return result
}

BorderHit :: proc(proj: Player_Projectile)-> bool{
	result : bool
	if proj.pos.x <= 0 || proj.pos.x >= GRID_WIDTH*CELL_SIZE || proj.pos.y >= GRID_WIDTH*CELL_SIZE{
		result = true
	}else{
		result = false
	}	
	return result
}

EnemyHit :: proc(proj: Player_Projectile){
}



CombatLogic :: proc(){
    if current_game_state == .Combat{   
    switch current_turn{
                case .Player:
                switch current_action{ 
                    case .Move:
                        if rl.IsKeyPressed(.K){
                            current_action = .Aim
                            Player_proj.dir = player.dir
                            if player.dir == Direction.Left{
                                Player_proj.angle = math.PI - math.RAD_PER_DEG*45
                                current_max_angle = LEFT_MAX_ANGLE
                                current_min_angle = LEFT_MIN_ANGLE
                                up_key = .DOWN
                                down_key = .UP
                            }else{
                                Player_proj.angle = math.RAD_PER_DEG*45
                                current_max_angle = MAX_ANGLE
                                current_min_angle = MIN_ANGLE
                                up_key = .UP 
                                down_key = .DOWN
                            }
                            Player_proj.strength = 0
                        }else{
                            MovePlayer()
                        }
                    case .Aim: 
                        if rl.IsKeyPressed(.K){
                            current_action = .Fire
                            Player_proj.pos.x = player.pos.x
                            Player_proj.pos.y = player.pos.y
                            Player_proj.state = .Travelling
                            Player_proj.time = 0
                        }
                        if rl.IsKeyPressed(.T){
                            if Player_proj.type == Projectile_type.Bullet{
                                Player_proj.type  = Projectile_type.Fly
                            }else if Player_proj.type == Projectile_type.Fly{
                                Player_proj.type  = Projectile_type.Bullet                      
                            }
                        }else{
                            Player_proj = AimPlayerProjectile(Player_proj)
                        }
                    case .Fire: 
                        if rl.IsKeyPressed(.K) && Player_proj.state == .Travelling{
                            current_action = .Move
                        }else{
                            Player_proj = MoveProjectile(Player_proj)
                        }
                }
            case .Enemy:
                switch current_action{
                    case .Move: 
                        switch game_level{
                            case .Level1: 
                                /* 
                                projectile enemies have arching shots so they shouldnt have to much much to hit the player
								projectiles will arch meaning that if there is a wall above us we need to move so we dont hit it
								and if there is a wall in the way of the the shoot we need to move so we can hit the player
								*/
								if abs(level1_enemy.pos.x - player.pos.x) > 3{
									if !IsStuck(level1_enemy.pos,level1_enemy.dir){
										

									}

								}else{
									current_action = .Aim
								}
								fmt.print(level1_enemy.pos)
								
                            case .Level2:
                                /*
                                gun enemies have straight shooting shots when cannot go through walls so they will need to be able to move until 
                                they are in the light of sight of the player. (straight lineto player no walls)
								
								*/
                            case .Level3:
                         		/*
                                lazer enemies enemies have a limited lazer range, so they will have to move within range of there lazer, their movement is special,
                                as they teleport around. logic for teleporting is as follows. teleport horizontally until you reach your max teleport length, if you reach 
                                a wall before your teleport length we teleport to the top of the wall and placing ourselves on it. if we are teleporting horizontally and there
                                is no floor below us, we teleport to the nearest ground within the same column and end our horiontal movement.
                         		*/
                            case .Level4:
                            	/*
                                bomb enemies are going to have a shorter range than projectile enemis, to stick with the bomb theme they will do their movements by projectiling themselves,
                                similar to how the players fly mechanic works, there will be a maximum high to their  **bomb jump** unless there is a wall in their way in which they will
                                jump to the top of the wall. similar the teleport wall case
                            	*/

                            case .Level5:
                            	/*
                                melee enemies are going to move similar to players, but when encountering a wall they will jump to the top of it and when encountering an edge
                                jumping down it 
                            	*/ 
                        }
                    case .Aim:
                         switch game_level{
                            case .Level1: 
                            case .Level2:
                            case .Level3:
                            case .Level4:
                            case .Level5: 
                        }
                    case .Fire:
                         switch game_level{
                            case .Level1: 
                            case .Level2:
                            case .Level3:
                            case .Level4:
                            case .Level5: 
                        }
                }
        
        }
    }
}


Refresh :: proc(){
	player_pos= {0,13*CELL_SIZE}
	player_dir = Direction.Right
	player = {player_pos,10,0,player_dir}

	level1_enemy_dir = Direction.Left
	level1_enemy_pos = {18*CELL_SIZE,13*CELL_SIZE}
    level1_enemy = {level1_enemy_pos,10,level1_enemy_dir,10,0}
    level1_attack = {Attack {level1_enemy_pos,1}, ProjectileProperties {math.RAD_PER_DEG*45,0,1*CELL_SIZE}}


	level2_enemy_dir = Direction.Left
	level2_enemy_pos = {18*CELL_SIZE,13*CELL_SIZE} 
	level2_enemy = Gun_Enemy {}
    level2_enemy = Enemy {level2_enemy_pos,10,level2_enemy_dir,10,0}

	level3_enemy_dir = Direction.Left
	level3_enemy_pos = {18*CELL_SIZE,3*CELL_SIZE} 
 	level3_enemy = Lazer_Enemy {}
    level3_enemy = Enemy {level3_enemy_pos,10,level3_enemy_dir,10,0}

	level4_enemy_dir = Direction.Left
	level4_enemy_pos = {9*CELL_SIZE,17*CELL_SIZE} 
	level4_enemy = Bomb_Enemy {}
    level4_enemy = Enemy {level4_enemy_pos,10,level4_enemy_dir,25,0}
    

	level5_enemy_dir = Direction.Left
	level5_enemy_pos = {18*CELL_SIZE,13*CELL_SIZE} 
	level5_enemy = Melee_Enemy {}
    level5_enemy = Enemy {level5_enemy_pos,10,level5_enemy_dir,100,0}

	round_time = 30
	current_turn = Turn.Player
	prev_turn = Turn.Player
	current_action = Action.Move
	start_time = rl.GetTime()
	count_up = true
	reset = false
	current_game_state = Game_state.LevelSelector
}

main :: proc(){
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_SIZE,WINDOW_SIZE, "game")
	CreateMainPage()
	CreateLevelSelectorPage()
	CreateDefeatPage()
	CreateVictoryPage()
	CreateCombatpage()
	Refresh()
	
	for !rl.WindowShouldClose(){
		tick_timer = tick_timer - rl.GetFrameTime()
		move_direction = Direction.Left
		move_amount = 0
		//game clock logic
		if rl.IsKeyDown(.F){
			Refresh()
		}
		if tick_timer <= 0{
			tick_timer = TICK_RATE + tick_timer
		}
		
		// display drawing
		rl.BeginDrawing()
		camera := rl.Camera2D {
			zoom = f32(WINDOW_SIZE / CANVAS_SIZE)
		}
		rl.BeginMode2D(camera)
        CombatLogic()
		DrawUI()
		free_all(context.temp_allocator)
		rl.EndMode2D()
		rl.EndDrawing()
	}
	rl.CloseWindow()
}

