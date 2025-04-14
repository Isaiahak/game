package game

import rl "vendor:raylib"
import "core:math"
import "core:fmt"



MainPage:: struct{
	title: cstring, // some type of title
	option_bar: rl.Rectangle, 
	play_button: rl.Rectangle,
}

LevelSelectorPage:: struct{
	desc: cstring, // tells you to select a level
	level_bar : rl.Rectangle, // bar containing all of the levels
	level_1: rl.Rectangle,// I may want to make this bar dynamically
	level_2: rl.Rectangle,//
	level_3: rl.Rectangle,//
	level_4: rl.Rectangle,// 
	level_5: rl.Rectangle,
}

VictoryPage :: struct{
	title: cstring, // going to be a message telling you that you beat the stage
	options_bar: rl.Rectangle, // going to have options for playing again, going to the next level, or main menu
	play_again: rl.Rectangle,
	main_page: rl.Rectangle,
}

DefeatPage :: struct{
	title: cstring, // going to be a message telling you that you beat the stage
	options_bar: rl.Rectangle, // going to have options for playing again, going to the next level, or main menu
	play_again: rl.Rectangle,
	main_page: rl.Rectangle,
}

CombatPage:: struct{
	player: rl.Rectangle, // character drawn
	enemy: rl.Rectangle, // enemy drawn
	player_hp_bar: rl.Rectangle, // going to be a box which contains the player hp
	player_current_hp: rl.Rectangle,
	enemy_hp_bar: rl.Rectangle, // either hp bars above enemy heads or at the top of the screen for bosses
	enemy_current_hp: rl.Rectangle,
	combat_info: rl.Rectangle,
	current_action: cstring,
	current_pos: cstring,
	current_direction: cstring,
	current_strength: cstring,
	current_angle: cstring,
	current_projectile_type: cstring,
}

mouse_pos : rl.Vector2
main_page_image: rl.Texture2D
main_page : MainPage
level_selector_page : LevelSelectorPage
victory_page : VictoryPage
defeat_page : DefeatPage
combat_page : CombatPage
mouse_scaler := rl.Vector2 {0.5,0.5}
play_str : cstring = "Play!"
main_page_str : cstring = "Main Menu"
play_again_str : cstring = "Play Again"
level_1_str : cstring = "Level 1"
level_2_str : cstring = "Level 2"
level_3_str : cstring = "Level 3"
level_4_str : cstring = "Level 4"
level_5_str : cstring = "Level 5"
game_title : cstring = "Leah's Adventures"
current_enemy_hp : f32
current_enemy : Enemy


CreateMainPage :: proc(){
	main_page.option_bar = rl.Rectangle {0,14*CELL_SIZE,CANVAS_SIZE,2.5*CELL_SIZE}
	main_page.play_button = rl.Rectangle {8*CELL_SIZE,14.5*CELL_SIZE,CELL_SIZE*4,1.5*CELL_SIZE}
	main_page_image:=rl.LoadTexture("mainpage.png")
}

CreateLevelSelectorPage :: proc(){
	level_selector_page.level_bar = rl.Rectangle {0,6.75*CELL_SIZE,CANVAS_SIZE,3.5*CELL_SIZE}
	level_selector_page.level_1 = rl.Rectangle {0.25*CELL_SIZE,7.5*CELL_SIZE,3*CELL_SIZE,2*CELL_SIZE}
	level_selector_page.level_2 = rl.Rectangle {4.25*CELL_SIZE,7.5*CELL_SIZE,3*CELL_SIZE,2*CELL_SIZE}
	level_selector_page.level_3 = rl.Rectangle {8.5*CELL_SIZE,7.5*CELL_SIZE,3*CELL_SIZE,2*CELL_SIZE}
	level_selector_page.level_4 = rl.Rectangle {12.75*CELL_SIZE,7.5*CELL_SIZE,3*CELL_SIZE,2*CELL_SIZE}
	level_selector_page.level_5 = rl.Rectangle {16.75*CELL_SIZE,7.5*CELL_SIZE,3*CELL_SIZE,2*CELL_SIZE}
}

CreateVictoryPage :: proc(){
	victory_page.title = "Victory!" 
	victory_page.options_bar = rl.Rectangle {0,14*CELL_SIZE,CANVAS_SIZE,2.5*CELL_SIZE}
	victory_page.play_again = rl.Rectangle {4*CELL_SIZE,14.5*CELL_SIZE,CELL_SIZE*5,1.5*CELL_SIZE}
	victory_page.main_page = rl.Rectangle {11*CELL_SIZE,14.5*CELL_SIZE,CELL_SIZE*5,1.5*CELL_SIZE}
}	

CreateDefeatPage :: proc(){
	defeat_page.title = "Defeat!!!!"
	defeat_page.options_bar = rl.Rectangle {0,14*CELL_SIZE,CANVAS_SIZE,2.5*CELL_SIZE}
	defeat_page.play_again = rl.Rectangle {4*CELL_SIZE,14.5*CELL_SIZE,CELL_SIZE*5,1.5*CELL_SIZE}
	defeat_page.main_page = rl.Rectangle {11*CELL_SIZE,14.5*CELL_SIZE,CELL_SIZE*5,1.5*CELL_SIZE}
}

CreateCombatpage :: proc(){
	combat_page.combat_info = rl.Rectangle {5*CELL_SIZE,0,8*CELL_SIZE,3*CELL_SIZE,}
}

DrawUI :: proc(){
	mouse_pos = rl.GetMousePosition() * mouse_scaler
	switch current_game_state{
		case .MainPage:
			rl.ClearBackground(rl.WHITE)
			source_mp := rl.Rectangle {0,0,f32(main_page_image.width),f32(main_page_image.height)}
			destination_mp := rl.Rectangle {0,0,f32(CANVAS_SIZE),f32(CANVAS_SIZE)}
			//rl.DrawTexturePro(main_page_image,source_mp,destination_mp,0,0,rl.WHITE)
			rl.DrawRectangleRec(main_page.option_bar,rl.DARKGRAY)
			rl.DrawRectangleRec(main_page.play_button,rl.GRAY)
			rl.DrawText(play_str,9.5*CELL_SIZE,15*CELL_SIZE,6,rl.WHITE)
			rl.DrawText(game_title,1*CELL_SIZE,6*CELL_SIZE,30,rl.DARKBLUE)
			if rl.IsMouseButtonPressed(.LEFT){
				
				if rl.CheckCollisionPointRec(mouse_pos,main_page.play_button){
					current_game_state = .LevelSelector	
				}
			}
		case .LevelSelector:
			rl.ClearBackground(rl.WHITE)
			rl.DrawRectangleRec(level_selector_page.level_bar,rl.DARKGRAY)
			rl.DrawRectangleRec(level_selector_page.level_1,rl.GRAY)
			rl.DrawText(level_1_str,0.75*CELL_SIZE,8*CELL_SIZE,4,rl.WHITE)
			rl.DrawRectangleRec(level_selector_page.level_2,rl.GRAY)
			rl.DrawText(level_2_str,4.75*CELL_SIZE,8*CELL_SIZE,4,rl.WHITE)
			rl.DrawRectangleRec(level_selector_page.level_3,rl.GRAY)
			rl.DrawText(level_3_str,9*CELL_SIZE,8*CELL_SIZE,4,rl.WHITE)
			rl.DrawRectangleRec(level_selector_page.level_4,rl.GRAY)
			rl.DrawText(level_4_str,13*CELL_SIZE,8*CELL_SIZE,4,rl.WHITE)
			rl.DrawRectangleRec(level_selector_page.level_5,rl.GRAY)
			rl.DrawText(level_5_str,17*CELL_SIZE,8*CELL_SIZE,4,rl.WHITE)
			if rl.IsMouseButtonPressed(.LEFT){
				if rl.CheckCollisionPointRec(mouse_pos,level_selector_page.level_1){
					game_level = .Level1
					current_map = Map1
					player.pos= {0,13*CELL_SIZE}
				}
				else if rl.CheckCollisionPointRec(mouse_pos,level_selector_page.level_2){
					game_level = .Level2
					current_map = Map2
					player.pos = {2*CELL_SIZE,11*CELL_SIZE}
				}
				else if rl.CheckCollisionPointRec(mouse_pos,level_selector_page.level_3){
					game_level = .Level3
					current_map = Map3
					player.pos = {2*CELL_SIZE,11*CELL_SIZE}
				}
				else if rl.CheckCollisionPointRec(mouse_pos,level_selector_page.level_4){
					game_level = .Level4
					current_map = Map4
					player.pos = {2*CELL_SIZE,17*CELL_SIZE}
				}
				else if rl.CheckCollisionPointRec(mouse_pos,level_selector_page.level_5){
					game_level = .Level5
					current_map = Map5
					player.pos = {2*CELL_SIZE,1*CELL_SIZE}
				}
				current_turn = .Player
				current_action = .Move
				current_game_state = .Combat
			}
		case .Defeat:
			rl.ClearBackground(rl.WHITE)	
			rl.DrawText(defeat_page.title,4.5*CELL_SIZE,5*CELL_SIZE,40,rl.DARKGRAY)
			rl.DrawRectangleRec(defeat_page.options_bar,rl.DARKGRAY)
			rl.DrawRectangleRec(defeat_page.main_page,rl.GRAY)
			rl.DrawText(main_page_str,5.5*CELL_SIZE,15*CELL_SIZE,6,rl.WHITE)
			rl.DrawText(play_again_str,12.5*CELL_SIZE,15*CELL_SIZE,6,rl.WHITE)
			rl.DrawRectangleRec(defeat_page.play_again,rl.GRAY)
			if rl.IsMouseButtonPressed(.LEFT){
				if rl.CheckCollisionPointRec(mouse_pos,defeat_page.play_again){
					//figure out level selection
				}
				else if rl.CheckCollisionPointRec(mouse_pos,defeat_page.main_page){
					current_game_state = .MainPage
				}
			}
		case .Victory:
			rl.ClearBackground(rl.WHITE)
			rl.DrawText(victory_page.title,4.5*CELL_SIZE,5*CELL_SIZE,40,rl.DARKGRAY)
			rl.DrawRectangleRec(victory_page.options_bar,rl.DARKGRAY)
			rl.DrawRectangleRec(victory_page.main_page,rl.GRAY)
			rl.DrawRectangleRec(victory_page.play_again,rl.GRAY)
			rl.DrawText(main_page_str,5.5*CELL_SIZE,15*CELL_SIZE,6,rl.WHITE)
			rl.DrawText(play_again_str,12.5*CELL_SIZE,15*CELL_SIZE,6,rl.WHITE)
			if rl.IsMouseButtonPressed(.LEFT){
				if rl.CheckCollisionPointRec(mouse_pos,victory_page.play_again){
					//figure out level selection
				}
				else if rl.CheckCollisionPointRec(mouse_pos,victory_page.main_page){
					current_game_state = .MainPage
				}
			}
		case .Combat:
			rl.ClearBackground(rl.WHITE)
			for i in 0..<GRID_WIDTH{
				for j in 0..<GRID_WIDTH{
					if current_map[i][j] == true {
						rl.DrawRectangleRec(rl.Rectangle {f32(j)*CELL_SIZE,f32(i)*CELL_SIZE,CELL_SIZE,CELL_SIZE,},rl.MAROON)
					}else{
						rl.DrawRectangleRec(rl.Rectangle {f32(j)*CELL_SIZE,f32(i)*CELL_SIZE,CELL_SIZE,CELL_SIZE,}, rl.BLUE)
					}
				}
			}
			if Player_proj.state == .Travelling{
				rl.DrawCircleV(Player_proj.pos,CELL_SIZE/4,rl.BLACK)
			}
			rl.DrawRectangleRec(combat_page.combat_info,rl.Color {130, 130, 130, 100})
			combat_page.player_hp_bar = rl.Rectangle {player.pos.x,player.pos.y-10,CELL_SIZE,5}
			combat_page.player_current_hp = rl.Rectangle {player.pos.x,player.pos.y-10,1.6*player.hp,5}

			combat_page.player = rl.Rectangle {f32(player.pos.x),f32(player.pos.y),CELL_SIZE,CELL_SIZE,}
			switch game_level{
				case .Level1:
					current_enemy = level1_enemy
					combat_page.enemy = rl.Rectangle {current_enemy.pos.x,current_enemy.pos.y,CELL_SIZE,CELL_SIZE,}
					current_enemy_hp = level1_enemy.hp
					combat_page.enemy_hp_bar = rl.Rectangle {current_enemy.pos.x,current_enemy.pos.y-10,CELL_SIZE,5}
					combat_page.enemy_current_hp =  rl.Rectangle {current_enemy.pos.x,current_enemy.pos.y-10,1.6*current_enemy_hp,5}
				case .Level2:
					current_enemy := level2_enemy.(Enemy)
					combat_page.enemy = rl.Rectangle {level2_enemy.(Enemy).pos.x,level2_enemy.(Enemy).pos.y,CELL_SIZE,CELL_SIZE,}
					current_enemy_hp = level2_enemy.(Enemy).hp
					combat_page.enemy_hp_bar = rl.Rectangle {current_enemy.pos.x,current_enemy.pos.y-10,CELL_SIZE,5}
					combat_page.enemy_current_hp =  rl.Rectangle {current_enemy.pos.x,current_enemy.pos.y-10,1.6*current_enemy_hp,5}
				case .Level3:
					current_enemy := level3_enemy.(Enemy)
					combat_page.enemy = rl.Rectangle {level3_enemy.(Enemy).pos.x,level3_enemy.(Enemy).pos.y,CELL_SIZE,CELL_SIZE,}
					current_enemy_hp = level3_enemy.(Enemy).hp
					combat_page.enemy_hp_bar = rl.Rectangle {current_enemy.pos.x,current_enemy.pos.y-10,CELL_SIZE,5}
					combat_page.enemy_current_hp =  rl.Rectangle {current_enemy.pos.x,current_enemy.pos.y-10,1.6*current_enemy_hp,5}
				case .Level4:
					current_enemy := level4_enemy.(Enemy)
					combat_page.enemy = rl.Rectangle {level4_enemy.(Enemy).pos.x,level4_enemy.(Enemy).pos.y,CELL_SIZE,CELL_SIZE,}
					current_enemy_hp = level4_enemy.(Enemy).hp
					combat_page.enemy_hp_bar = rl.Rectangle {current_enemy.pos.x,current_enemy.pos.y-10,CELL_SIZE,5}
					combat_page.enemy_current_hp =  rl.Rectangle {current_enemy.pos.x,current_enemy.pos.y-10,1.6*current_enemy_hp,5}
				case .Level5:
					current_enemy := level5_enemy.(Enemy)
					combat_page.enemy = rl.Rectangle {level5_enemy.(Enemy).pos.x,level5_enemy.(Enemy).pos.y,CELL_SIZE,CELL_SIZE,}
					current_enemy_hp = level5_enemy.(Enemy).hp
					combat_page.enemy_hp_bar = rl.Rectangle {current_enemy.pos.x,current_enemy.pos.y-10,CELL_SIZE,5}
					combat_page.enemy_current_hp =  rl.Rectangle {current_enemy.pos.x,current_enemy.pos.y-10,1.6*current_enemy_hp,5}
			}
			rl.DrawRectangleRec(combat_page.player_hp_bar,rl.Color {102,5,5,255})
			rl.DrawRectangleRec(combat_page.player_current_hp,rl.RED)
			rl.DrawRectangleRec(combat_page.enemy_hp_bar,rl.Color {102,5,5,255})
			rl.DrawRectangleRec(combat_page.enemy_current_hp,rl.RED)
			rl.DrawRectangleRec(combat_page.player,rl.WHITE)
			rl.DrawRectangleRec(combat_page.enemy,rl.GREEN)
			combat_page.current_action = fmt.ctprintf("Action: %v", current_action)
			rl.DrawText(combat_page.current_action,CANVAS_SIZE/2 -4*CELL_SIZE,8,8,rl.WHITE)
			switch current_turn{
				case .Player:
					#partial switch current_action{
						case .Move:
							combat_page.current_pos = fmt.ctprintf("Position: [%v,%v]", int(player.pos.x/CELL_SIZE),int(player.pos.y/CELL_SIZE))
							rl.DrawText(combat_page.current_pos,CANVAS_SIZE/2 -4*CELL_SIZE,20,8,rl.WHITE)
							combat_page.current_direction = fmt.ctprintf("Direction: %v", player.dir)
							rl.DrawText(combat_page.current_direction,CANVAS_SIZE/2 -4*CELL_SIZE,32,8,rl.WHITE)

						case .Aim:
							if player.dir == .Right{
								combat_page.current_angle = fmt.ctprintf("Angle %v", int(Player_proj.angle * math.DEG_PER_RAD))
							}else{
								combat_page.current_angle = fmt.ctprintf("Angle %v", int((math.PI - Player_proj.angle ) * math.DEG_PER_RAD)) 				
							}
							rl.DrawText(combat_page.current_angle,CANVAS_SIZE/2 -4*CELL_SIZE,24,8,rl.WHITE)
							combat_page.current_strength = fmt.ctprintf("Shoot Strength %v", int(Player_proj.strength))
							rl.DrawText(combat_page.current_strength,CANVAS_SIZE/2 -4*CELL_SIZE,32,8,rl.WHITE)
							combat_page.current_projectile_type= fmt.ctprintf("Projectile Type: %v", Player_proj.type)
							rl.DrawText(combat_page.current_projectile_type,CANVAS_SIZE/2 -4*CELL_SIZE,40,8,rl.WHITE)
						//case. Fire:
					}
				case .Enemy:
			}
	}
}