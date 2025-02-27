extends CharacterBody2D

const SPEED = 140.0
const RUN_SPEED = 220.0
const RUN_DURATION = 0.15 

signal hit

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"."
@onready var area_2d: Area2D = $Area2D

var is_running = false

func _physics_process(delta: float) -> void:
	var direction := Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)

	if Input.is_action_just_pressed("run") and not is_running:
		is_running = true
		velocity = direction.normalized() * (SPEED + RUN_SPEED)
		await get_tree().create_timer(RUN_DURATION).timeout
		is_running = false # Back to normal speed

	if direction.length() > 0:
		direction = direction.normalized()
		velocity = direction * (SPEED + RUN_SPEED) if is_running else direction * SPEED
		
		if direction.y < 0:
			animated_sprite_2d.flip_v = true
		elif direction.y > 0:
			animated_sprite_2d.flip_v = false
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _on_area_2d_area_entered(area: Area2D) -> void:
	player.queue_free()
	hit.emit()
	
func _on_game_time_timeout() -> void:
	if not area_2d is CollisionObject2D:
		print("ERROR: area_2d bukan CollisionObject2D!")
		return
	
	print("timeout from player")
	
	## Nonaktifkan collision player
	#$CollisionShape2D.disabled = true  

	# Nonaktifkan collision Area2D
	area_2d.get_child(0).disabled = true 
	
	print("Collision dinonaktifkan")
