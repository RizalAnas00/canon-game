extends Area2D

var player:CharacterBody2D
var velocity: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta  # Menggerakkan misil berdasarkan kecepatan

func _on_body_entered(body: Node) -> void:
	print("Collided with: ", body.name)
	if body is CharacterBody2D:
		print("It's a CharacterBody2D")
		queue_free()
