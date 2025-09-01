extends CharacterBody2D

const SPEED = 140.0
var RUN_SPEED = 360.0
const RUN_DURATION = 0.1 

signal hit

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var collision_shape_2d_player: CollisionShape2D = $CollisionShape2D

var is_running = false

func _physics_process(delta: float) -> void:
	collision_shape_2d.disabled = true
	
	var direction := Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)

	if Input.is_action_just_pressed("run") and not is_running:
		is_running = true
		velocity = direction.normalized() * (SPEED + RUN_SPEED)
		await get_tree().create_timer(RUN_DURATION).timeout
		is_running = false # Kembali ke kecepatan normal

	if direction.length() > 0:
		direction = direction.normalized()
		velocity = direction * (SPEED + RUN_SPEED) if is_running else direction * SPEED

		# Atur rotasi berdasarkan arah
		if abs(direction.x) > abs(direction.y):  
			if direction.x > 0:  
				animated_sprite_2d.rotation_degrees = 90  # Ke kanan
				collision_shape_2d.rotation_degrees = 0
				collision_shape_2d_player.rotation_degrees = 0
			else:  
				animated_sprite_2d.rotation_degrees = -90 # Ke kiri
				collision_shape_2d.rotation_degrees = 0
				collision_shape_2d_player.rotation_degrees = 0

		else:  
			if direction.y > 0:  
				animated_sprite_2d.rotation_degrees = 180  # Ke bawah
				collision_shape_2d.rotation_degrees = 90
				collision_shape_2d_player.rotation_degrees = 90
			else:  
				animated_sprite_2d.rotation_degrees = 0    # Ke atas
				collision_shape_2d.rotation_degrees = 90
				collision_shape_2d_player.rotation_degrees = 90

		animated_sprite_2d.play("walk")  
	else:
		velocity = Vector2.ZERO
		animated_sprite_2d.stop()

	move_and_slide()

func _on_area_2d_area_entered(area: Area2D) -> void:
	player.queue_free()
	hit.emit()
	set_run_speed(350.0)
	
func _on_game_time_timeout() -> void:
	print("timeout from player")
	
	## Nonaktifkan collision player
	#$CollisionShape2D.disabled = true  

	# Nonaktifkan collision Area2D
	collision_shape_2d.disabled = true 
	set_run_speed(350.0)
	print("Collision dinonaktifkan")
	
func set_run_speed(num: float):
	RUN_SPEED = num
