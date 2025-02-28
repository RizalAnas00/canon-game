extends Area2D
@export var eksplosion_time: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = eksplosion_time
	$Timer.start()

func _on_timer_timeout():
	explode()

func eksplode():
	queue_free()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
