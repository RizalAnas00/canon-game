extends Node2D

@onready var camera = $Camera2D
@onready var missile_path: Path2D = $MissilePath
@onready var missile_spawn: PathFollow2D = $MissilePath/MissileSpawn
@onready var missiles: Node2D = $Missiles  
@onready var player: CharacterBody2D = $Player
@onready var game_time: Timer = $GameTime
@onready var countdown: Label = $Countdown

@export var missile_scene: PackedScene  
@export var spawn_interval: float = 1  # Interval awal spawn misil
@export var min_spawn_interval: float = 0.11  # Batas minimal interval spawn

@onready var canon: CharacterBody2D = $Canon
@onready var canon_2: CharacterBody2D = $Canon2
@onready var canon_3: CharacterBody2D = $Canon3
@onready var canon_4: CharacterBody2D = $Canon4

var has_spawn_started = false
var timer: Timer  

func _ready() -> void:
	if not is_instance_valid(missiles):
		print("Missiles node is missing!")
		return
		
	# countdown 10 detik
	game_time.wait_time = 6
	game_time.start()
	game_time.timeout.connect(_on_game_time_timeout)
	
	game_time.timeout.connect(player.call_deferred.bind("_on_game_time_timeout"))
	
	print("Spawn Interval: ", spawn_interval)

func _process(delta: float) -> void:
	if game_time.is_stopped():
		countdown.global_position = player.global_position + Vector2(-32, -50)
		
	if game_time.time_left > 0:
		countdown.text = str(ceil(game_time.time_left))
		countdown.global_position = player.global_position + Vector2(-12, -50)
		
		# Jika waktu tersisa 5 detik atau kurang, mulai spawn misil
		if game_time.time_left <= 5 and not has_spawn_started:				
			has_spawn_started = true  # Set flag
			
			timer = Timer.new()
			timer.wait_time = spawn_interval
			timer.autostart = true
			timer.timeout.connect(_spawn_missile)
			add_child(timer)
	
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
	var speed = randf_range(340.0, 470.0)
	new_missile.velocity = direction_vector * speed  # Gerakkan ke arah kanon
	
	# Tambahkan misil ke dalam node "missiles"
	missiles.add_child(new_missile)
	
	# Semakin sedikit waktu, semakin sedikit interval spawnnya
	spawn_interval = max(spawn_interval - 0.3, min_spawn_interval)
	timer.wait_time = spawn_interval  # Perbarui waktu tunggu timer
	print("Spawn Interval Disini: ", spawn_interval)
	
func _on_player_hit() -> void:
	get_tree().reload_current_scene()
	
func _on_game_time_timeout() -> void:
	if is_instance_valid(player):   
		game_time.stop()
		
		#if is_instance_valid(timer):
			#timer.stop()
			#timer.queue_free()  
		#
		#has_spawn_started = false		
		countdown.text = "RISPEK"
