package game

import rl "vendor:raylib"
import "core:math"
import "core:fmt"



Enemy :: struct{
	pos: rl.Vector2,
	hp: f32, 
	dir: Direction,
	move: f32,
	current_move: f32,
}
// enemy type,  lazer attack type
Lazer_Enemy :: union{
	Enemy,
	Lazer, 
}
// enemy type, bullet attack type
Gun_Enemy :: union{
	Enemy,
	Bullet, 
}
 // enemy type, projectile attack type
Projectile_Enemy :: union{
 	Enemy, 
	Projectile, 
}
// enemy type, melee attack type
Melee_Enemy :: union{
	Enemy, 
	Melee, 
}
// enemy type, bomb attack type
Bomb_Enemy :: union{
	Enemy, 
	Bomb, 
}