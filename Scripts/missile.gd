extends Area2D

var player:CharacterBody2D
var velocity: Vector2 = Vector2.ZERO
#var posExit: Vector2
#var velocExit: Vector2
var belong_to: String = "canon"
signal send_exit
@onready var missiles: Area2D = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	missiles.add_to_group("missile_scene")
	print(" group name of missiles : ", get_groups())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta

	#var viewport_rect = get_viewport_rect()
	#print("viewport : ", viewport_rect)
	#if not viewport_rect.has_point(global_position):
		#queue_free()
		#
func _on_body_entered(body: Node) -> void:
	print("Collided with: ", body.name)
	if body is CharacterBody2D:
		print("It's a CharacterBody2D")
		queue_free()
		
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#posExit = global_position
	#velocExit = velocity
	send_exit.emit()
	
	#print("pos when exit : ", posExit)
	#print("velocity when exit : ", velocExit)
	#
#func get_pos_velocity_exit() -> String:
	#var data := {
		#"posExit": {"x": posExit.x, "y": posExit.y},
		#"velocExit": {"x": velocExit.x, "y": velocExit.y}
	#}
	#return JSON.stringify(data)
	
func set_belongs_to(canon_name: String) -> void:
	belong_to = canon_name
	
func get_belongs_to() -> String:
	return belong_to
	
func set_reverse_collision() -> void:
	collision_layer = 1
