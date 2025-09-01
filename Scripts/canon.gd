extends CharacterBody2D

@onready var marker_2d: Marker2D = $MissileSpawn
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	print("Posisi global MissileSpawn:", marker_2d.global_position)
	
func shoot():
	animated_sprite_2d.play("shoot")
	
func not_shoot():
	animated_sprite_2d.play("idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "shoot":
		not_shoot()
