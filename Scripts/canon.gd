extends CharacterBody2D

@onready var marker_2d: Marker2D = $MissileSpawn
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	print("Posisi global MissileSpawn:", marker_2d.global_position)
	
func shoot():
	animated_sprite_2d.play("shoot")
	
func not_shoot():
	animated_sprite_2d.play("idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "shoot":
		not_shoot()
		
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("missile_scene") and check_missile(area):
		area.queue_free()
		
func check_missile(missile: Area2D) -> bool:
	if missile.get_belongs_to() == name :
		return true
		
	return false
