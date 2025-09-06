extends Node2D

@onready var camera = $Camera2D
@onready var missiles: Node2D = $Missiles  
@onready var player: CharacterBody2D = $Player
@onready var game_time: Timer = $GameTime
@onready var countdown: Label = $Countdown

@export var missile_speed: Vector2 = Vector2(340.0, 390.0) # range speed x = min, y = max
@export var missile_scene: PackedScene  
@export var spawn_interval: float = 2
@export var min_spawn_interval: float = 0.7 

var set_spawn_interval: float
var set_min_spawn_interval: float

@onready var canon: CharacterBody2D = $Canon
@onready var canon_2: CharacterBody2D = $Canon2
@onready var canon_3: CharacterBody2D = $Canon3
@onready var canon_4: CharacterBody2D = $Canon4

var has_spawn_started: bool = false
var start_reversing: bool = false
var has_reset_interval: bool = false

var timer: Timer  
var reverse_timer: Timer
var stored_missiles: Array = []  # Save last position when out of screen
var reverse_queue: Array = []

func _ready() -> void:
	if not is_instance_valid(missiles):
		print("Missiles node is missing!")
		return
		
	start_reversing = false
	set_spawn_interval = spawn_interval
	set_min_spawn_interval = min_spawn_interval
	
	timer = Timer.new()
	reverse_timer = Timer.new()
	
	# Timer 10s
	game_time.wait_time = 10
	game_time.start()
	#game_time.timeout.connect(_on_game_time_timeout)
	game_time.timeout.connect(player.call_deferred.bind("_on_game_time_timeout"))

	print("Initial Spawn Interval: ", spawn_interval)

func _process(delta: float) -> void:
	if game_time.is_stopped():
		countdown.global_position = player.global_position + Vector2(-32, -50)
		
	if game_time.time_left > 0:
		countdown.text = str(ceil(game_time.time_left))
		countdown.global_position = player.global_position + Vector2(-12, -50)
		
		# 10-5 seconds, spawn missiles from canons
		if game_time.time_left > 5 and not has_spawn_started:				
			_start_spawn_phase()
		
		# in 5 seconds, spawn the out missile to inside again / reverse
		if game_time.time_left <= 5 and has_spawn_started and not has_reset_interval:
			_start_reverse_phase()
			
	if game_time.time_left == 0 :
		print("get count of new missiles child : ", missiles.get_child_count())
		game_time.stop()
		
	# Canon always point to player / or to reverse missiles that belong to them
	for c in [canon, canon_2, canon_3, canon_4]:
		if not start_reversing:
			# Normal phase: lock player
			c.rotation = (player.global_position - c.global_position).angle()
		else:
			# Reverse phase: find missile that 'belongs_to' this canon
			var target_missile = null
			var best_dist = 1e20

			for m in missiles.get_children():
				if not is_instance_valid(m):
					continue
					
				var owner_name = m.get_belongs_to()
				if owner_name == c.name:
					var d = c.global_position.distance_to(m.global_position)
					if d < best_dist:
						best_dist = d
						target_missile = m

			if target_missile:
				# direct snap to missile
				#c.rotation = (target_missile.global_position - c.global_position).angle()
				# smooth rotation
				var target_ang = (target_missile.global_position - c.global_position).angle()
				c.rotation = lerp_angle(c.rotation, target_ang, clamp(delta * 8.0, 0.0, 1.0))

func _start_spawn_phase() -> void:
	has_spawn_started = true
	start_reversing = false
	
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(_spawn_missile)
	add_child(timer)
	
func _start_reverse_phase():
	spawn_interval = set_spawn_interval
	min_spawn_interval = set_min_spawn_interval
	#print("spawn interval NOW : ", spawn_interval)
	has_reset_interval = true
				
	start_reversing = true
	reverse_timer.wait_time = spawn_interval
	reverse_timer.autostart = true
	reverse_timer.timeout.connect(_reverse_missiles)
	add_child(reverse_timer)
	player.set_run_speed(1000.0)

func _spawn_missile() -> void:
	if not start_reversing:
		if game_time.time_left <= 5.8:
			return
			
		if not missile_scene:
			print("ERROR: Missile scene is not assigned!")
			return
		
		# pick random canon as spawnpoint
		var canon_list = [canon, canon_2, canon_3, canon_4]
		var spawn_canon: CharacterBody2D = canon_list[randi() % canon_list.size()]

		# Take position from Marker2D inside of canon scene
		var missile_spawn_marker = spawn_canon.get_node_or_null("MissileSpawn")

		if missile_spawn_marker == null:
			print("ERROR: Couldn't find MissileSpawn node in ", spawn_canon.name)
			return

		# new missile spawn in Marker2D pos
		var new_missile = missile_scene.instantiate()
		new_missile.global_position = missile_spawn_marker.global_position

		print("Missile launched from: ", spawn_canon.name, " at position", new_missile.global_position)

		# direction to player
		var target_position = player.global_position
		var direction_vector = (target_position - new_missile.global_position).normalized()

		new_missile.rotation = direction_vector.angle()
		new_missile.velocity = direction_vector * randf_range(340.0, 390.0)
		
		spawn_canon.shoot()

		# Save last position before out of screen
		new_missile.connect("send_exit", Callable(self, "_on_missile_exiting").bind(new_missile, spawn_canon.global_position, spawn_canon.name))
		
		# Add missile to main node
		missiles.add_child(new_missile)
		
		# Fasten spawn interval
		spawn_interval = max(spawn_interval - 0.1, min_spawn_interval)
		timer.wait_time = spawn_interval
		print("Updated Spawn Interval:", spawn_interval)

func _on_missile_exiting(missile, canon_pos: Vector2, canon_name: String) -> void:
	if is_instance_valid(missile):
		print("Missile exited at position:", missile.global_position)
		stored_missiles.append({
			"position": missile.global_position,
			"velocity": missile.velocity,
			"target" : canon_pos,
			"canon_name" : canon_name
		})
		missile.queue_free()

func _reverse_missiles() -> void:
	if reverse_queue.is_empty():
		if not stored_missiles.is_empty():
			reverse_queue = stored_missiles.duplicate()
			stored_missiles.clear()
		else:
			return
	
	_spawn_reverse_missile()
	
func _spawn_reverse_missile() -> void:
	if reverse_queue.is_empty():
		return
	
	var missile_data = reverse_queue.pop_front()
	var new_missile = missile_scene.instantiate()
	new_missile.global_position = missile_data["position"]
	
	# arahkan ke canon
	var direction_vector = (missile_data["target"] - new_missile.global_position).normalized()
	new_missile.rotation = direction_vector.angle()
	new_missile.velocity = direction_vector * missile_data["velocity"].length()
	
	missiles.add_child(new_missile)
	new_missile.set_belongs_to(missile_data["canon_name"])
	new_missile.set_reverse_collision()
	
	# interval juga dipercepat sama seperti forward spawn
	spawn_interval = max(spawn_interval - 0.1, min_spawn_interval)
	reverse_timer.wait_time = spawn_interval
	print("Reverse Missile Spawned. Updated Spawn Interval:", spawn_interval)
	
func _on_player_hit() -> void:
	get_tree().call_deferred("reload_current_scene")

func _on_game_time_timeout() -> void:
	if is_instance_valid(player):   
		game_time.stop()
		countdown.text = "RESPECT"
