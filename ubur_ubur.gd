extends Sprite2D

# Ubur-ubur - gerakan natural mengambang dengan rotasi
@export var speed: float = 18.0
@export var swim_range: float = 70.0
@export var rotation_speed: float = 3.0  # Kecepatan rotasi

var start_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var move_timer: float = 0.0
var pulse_time: float = 0.0
var target_rotation: float = 0.0

func _ready() -> void:
	start_position = global_position
	target_position = global_position
	move_timer = 0.0
	pulse_time = randf() * TAU
	_pick_new_target()
	
	var anim = $AnimatedSprite2D
	if anim:
		anim.play("default")

func _process(delta: float) -> void:
	# Efek pulse
	pulse_time += delta * 2.0
	var pulse_scale = 1.0 + sin(pulse_time) * 0.05
	scale = Vector2(pulse_scale, pulse_scale)
	
	# Bergerak pelan menuju target
	var direction = (target_position - global_position)
	var distance = direction.length()
	
	if distance > 5.0:
		direction = direction.normalized()
		
		# Hitung rotasi berdasarkan arah gerak
		# 0 = menghadap atas, 90 = menghadap kanan, dst
		target_rotation = direction.angle() + PI/2  # +90 derajat karena sprite default hadap atas
		
		# Smooth rotation
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
		
		# Gerakan
		var move_speed = speed * (0.5 + sin(pulse_time) * 0.5)
		global_position += direction * move_speed * delta
	else:
		# Sudah sampai target
		move_timer -= delta
		if move_timer <= 0:
			_pick_new_target()

func _pick_new_target() -> void:
	var angle = randf() * TAU
	var distance = randf_range(swim_range * 0.3, swim_range)
	target_position = start_position + Vector2(
		cos(angle) * distance * 0.6,
		sin(angle) * distance
	)
	move_timer = randf_range(1.0, 3.0)
