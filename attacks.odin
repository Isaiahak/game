package game

import rl "vendor:raylib"
import "core:math"
import "core:fmt"



Attack :: struct{
	pos: rl.Vector2,
	damage: rl.Vector2,
}

//laser no gravity bounce off walls no border transfer
Lazer :: union{
	Attack, 
	LazerProperties,
}
LazerProperties :: struct{
	length: f32, // will determine how long the lazer remains length - travel distance until wall hit
	angle: f32,
	direction: Direction,
}
//bomb after a certain amount of turns we explode dealing aoe damage
Bomb :: union{
	Attack,
	BombProperties,
}

BombProperties :: struct{
	aoe: f32, //distance radius from player to deal damage
	timer: int // starts > 0 explodes on 0 
}

//bullet no gravity no bounce off walls no border transfer
Bullet :: struct{
	attack: Attack,
	bullet_properties: BulletProperties,
}

BulletProperties :: struct{
	angle: f32,
}
//projectile gravity
Projectile :: struct{
	attack: Attack,
	projectile_properties: ProjectileProperties,
}

ProjectileProperties :: struct{
	angle: f32, // initial angle for the projectile
	strength: f32, // initial strength of the projectile or we use the characters location to determine a strength
	gravity: f32, // projectile fall off
}

// melee with varying proximities
Melee :: union{
	Attack,
	MeleeProperties, 
}
MeleeProperties :: struct{
	range: f32, //distance radius from player to deal damage
}

AimLazer :: proc(lazer: Lazer, enemy: Lazer_Enemy)-> Lazer{
	lazer := lazer
	direction := player.pos-enemy.(Enemy).pos
	lazer_properties : LazerProperties = lazer.(LazerProperties)
	lazer_properties.angle = math.atan2_f32(direction.y,direction.x)
	lazer = lazer_properties
	return lazer
}

ShootLazer :: proc(lazer: Lazer, enemy: Lazer_Enemy) -> Lazer{
	lazer := lazer

	//we need to shoot the lazer at the lazer angle, if we hit a wall we we have two situations
	return lazer
}

//bullet no gravity no bounce off walls no border transfer
AimBullet :: proc(bullet: Bullet)-> Bullet{
	bullet := bullet
	return bullet
}
ShootBullet :: proc(bullet: Bullet)-> Bullet{
	bullet := bullet
	return bullet
}


AimProjectile :: proc(projectile: Projectile)-> Projectile{
	projectile := projectile
	return projectile
}
ShootProjectile :: proc(projectile: Projectile)-> Projectile{
	projectile := projectile
	return projectile
}
PerformMelee :: proc(melee: Melee){

}

AimBomb :: proc(bomb: Bomb)-> Bomb{
	bomb := bomb
	return bomb
}
explodeBomb :: proc(bomb: Bomb)-> Bomb{
	bomb := bomb
	return bomb
}