extends Node2D

@onready var camera = $Camera2D
@onready var missile_path: Path2D = $MissilePath
@onready var missile_spawn: PathFollow2D = $MissilePath/MissileSpawn
@onready var missiles: Node2D = $Missiles  
@onready var player: CharacterBody2D = $Player

@export var missile_scene: PackedScene  
@export var spawn_interval: float = 1.5  # Interval awal spawn misil
@export var min_spawn_interval: float = 0.3  # Batas minimal interval spawn

@onready var canon: CharacterBody2D = $Canon
@onready var canon_2: CharacterBody2D = $Canon2
@onready var canon_3: CharacterBody2D = $Canon3
@onready var canon_4: CharacterBody2D = $Canon4

var timer: Timer  

func _ready() -> void:
	if not is_instance_valid(missiles):
		print("Missiles node is missing!")
		return

	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(_spawn_missile)
	add_child(timer)
	print("Spawn Interval: ", spawn_interval)

func _spawn_missile() -> void:
	if not missile_scene:
		print("Missile scene not assigned!")
		return

	if not is_instance_valid(missiles):
		print("Missiles node has been freed!")
		return
	
	# Pilih posisi acak di sepanjang Path2D
	missile_spawn.progress_ratio = randf()

	# Buat instansiasi misil
	var new_missile = missile_scene.instantiate()
	new_missile.global_position = missile_spawn.global_position

	# Pilih salah satu kanon secara acak
	var canon_list = [canon, canon_2, canon_3, canon_4]
	var target_canon = canon_list[randi() % canon_list.size()]

	# Hitung arah menuju kanon
	var direction_vector = (target_canon.global_position - new_missile.global_position).normalized()
	var direction_angle = direction_vector.angle()

	# Atur rotasi misil agar mengarah ke target
	new_missile.rotation = direction_angle

	# Missile Speed 
	var speed = randf_range(200.0, 300.0)
	new_missile.velocity = direction_vector * speed  # Gerakkan ke arah kanon

	# Tambahkan misil ke dalam node "missiles"
	missiles.add_child(new_missile)

	# Semakin sedikit waktu, semakin sedikit interval spawnnya
	spawn_interval = max(spawn_interval - 0.1, min_spawn_interval)
	timer.wait_time = spawn_interval  # Perbarui waktu tunggu timer
	print("Spawn Interval: ", spawn_interval)

func _on_player_hit() -> void:
	get_tree().reload_current_scene()
