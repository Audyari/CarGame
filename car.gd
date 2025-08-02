extends CharacterBody2D

# Konstanta fisika mobil
var  ACCELERATION = 800.0
var MAX_SPEED = 100.0
var FRICTION = 400.0
var TURN_SPEED = 2.5
var DRIFT_FACTOR = 0.85
var MIN_SPEED_TO_TURN = 10.0


# Variabel untuk efek visual (opsional)
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready() -> void:
	# Setup awal jika diperlukan
	print("Car controller ready!")

func _physics_process(delta: float) -> void:
	

	
	handle_acceleration(delta)
	handle_steering(delta)
	apply_drift_physics()
	apply_friction(delta)
	limit_max_speed()
	
	if keluar_jalur:
		ACCELERATION = 300.0
		MAX_SPEED = 50.0
		FRICTION = 200.0
	else:
		ACCELERATION = 800.0
		MAX_SPEED = 100.0
		FRICTION = 400.0
		
	move_and_slide()

	handle_screen_bounds()

func handle_acceleration(delta: float) -> void:
	var acceleration_input = 0.0
	
	# Input untuk maju dan mundur
	if Input.is_action_pressed("ui_up"):
		acceleration_input = 1.0
	elif Input.is_action_pressed("ui_down"):
		acceleration_input = -0.7
	
	# Terapkan akselerasi jika ada input
	if acceleration_input != 0.0:
		var acceleration_vector = Vector2.RIGHT.rotated(rotation) * ACCELERATION * acceleration_input * delta
		velocity += acceleration_vector

func handle_steering(delta: float) -> void:
	var current_speed = velocity.length()
	
	# Tidak bisa belok jika kecepatan terlalu rendah
	if current_speed < MIN_SPEED_TO_TURN:
		return
	
	# Faktor kecepatan untuk steering yang lebih realistis
	var speed_factor = min(current_speed / MAX_SPEED, 1.0)
	
	# Deteksi apakah mobil sedang mundur
	var forward_dot = velocity.dot(Vector2.RIGHT.rotated(rotation))
	var is_reversing = forward_dot < 0
	
	# Balik arah steering jika mundur
	var turn_direction = 1.0
	if is_reversing:
		turn_direction = -1.0
	
	# Input steering
	var turn_input = 0.0
	if Input.is_action_pressed("ui_left"):
		turn_input = -1.0
	elif Input.is_action_pressed("ui_right"):
		turn_input = 1.0
	
	# Terapkan rotasi
	if turn_input != 0.0:
		rotation += TURN_SPEED * turn_input * turn_direction * speed_factor * delta

func apply_drift_physics() -> void:
	# Pisahkan velocity menjadi komponen maju dan samping
	var forward_direction = Vector2.RIGHT.rotated(rotation)
	var right_direction = Vector2.UP.rotated(rotation)
	
	var forward_velocity = velocity.dot(forward_direction)
	var right_velocity = velocity.dot(right_direction)
	
	# Kurangi velocity samping untuk efek drift
	right_velocity *= DRIFT_FACTOR
	
	# Gabungkan kembali velocity
	velocity = forward_direction * forward_velocity + right_direction * right_velocity

func apply_friction(delta: float) -> void:
	# Terapkan friction jika tidak ada input akselerasi
	if not Input.is_action_pressed("ui_up") and not Input.is_action_pressed("ui_down"):
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

func limit_max_speed() -> void:
	# Batasi kecepatan maksimum
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

func handle_screen_bounds() -> void:
	var screen_size = get_viewport_rect().size
	var pos = global_position
	var margin = 20
	
	pos.x = clamp(pos.x, margin, screen_size.x - margin)
	pos.y = clamp(pos.y, margin, screen_size.y - margin)

	if pos != global_position:
		if pos.x != global_position.x:
			velocity.x = 0
		if pos.y != global_position.y:
			velocity.y = 0
	
	global_position = pos
	
	# Clamp posisi
	pos.x = clamp(pos.x, margin, screen_size.x - margin)
	pos.y = clamp(pos.y, margin, screen_size.y - margin)

	# Tambahkan deteksi
	if pos != global_position:
		print("Nabrak batas layar!")
		
		if pos.x != global_position.x:
			velocity.x = 0
		if pos.y != global_position.y:
			velocity.y = 0
	
	global_position = pos
	
	# Clamp posisi agar tetap di dalam layar
	pos.x = clamp(pos.x, margin, screen_size.x - margin)
	pos.y = clamp(pos.y, margin, screen_size.y - margin)

	# ❗Tambahkan print di sini:
	if pos != global_position:
		print("Nabrak batas layar!")
		
		if pos.x != global_position.x:
			velocity.x = 0
		if pos.y != global_position.y:
			velocity.y = 0
	
	global_position = pos
	# Batasi mobil agar tidak keluar dari layar

	
	# Clamp posisi
	pos.x = clamp(pos.x, margin, screen_size.x - margin)
	pos.y = clamp(pos.y, margin, screen_size.y - margin)
	
	# Stop velocity jika menabrak batas
	if pos != global_position:
		if pos.x != global_position.x:
			velocity.x = 0
		if pos.y != global_position.y:
			velocity.y = 0
	
	global_position = pos

# Fungsi tambahan untuk debugging
func get_speed() -> float:
	return velocity.length()

func get_speed_kmh() -> float:
	# Konversi ke km/h (asumsi 1 unit = 1 meter)
	return velocity.length() * 3.6

var keluar_jalur = false

func _on_hit_area_area_exited(area: Area2D) -> void:
	if area.name == "Roud":
		print("🚨 Keluar jalur! Kecepatan diperlambat.")
		$AnimatedSprite2D.play("crash")
		velocity *= 0.5  # Perlambat kecepatan
		keluar_jalur = true


func _on_hit_area_area_entered(area: Area2D) -> void:
	if area.name == "Roud" and keluar_jalur:
		print("✅ Kembali ke jalur, kecepatan normal")
		$AnimatedSprite2D.play("default")
		keluar_jalur = false
