extends Sprite2D

# Ikan Biru - ikan kecil cepat
@export var speed: float = 45.0
@export var swim_range: float = 120.0
@export var default_faces_right: bool = true  # Set sesuai sprite asli

# State
var facing_right: bool = true
var start_position: Vector2 = Vector2.ZERO
var state_timer: float = 0.0
var wave_time: float = 0.0

func _ready() -> void:
	start_position = global_position
	state_timer = randf_range(2.0, 4.0)
	facing_right = randf() > 0.5
	wave_time = randf() * TAU
	_update_flip()
	
	var anim = $AnimatedSprite2D
	if anim:
		anim.play("default")

func _process(delta: float) -> void:
	# Gerakan wave untuk natural swimming
	wave_time += delta * 2.0
	var vertical_offset = sin(wave_time) * 5.0
	
	# Selalu bergerak ke arah hadap
	var move_direction = 1.0 if facing_right else -1.0
	global_position.x += move_direction * speed * delta
	global_position.y = start_position.y + vertical_offset
	
	# Timer untuk ganti arah
	state_timer -= delta
	if state_timer <= 0:
		state_timer = randf_range(2.0, 5.0)
		if randf() > 0.5:
			facing_right = not facing_right
			_update_flip()
	
	# Jaga dalam range - balik jika terlalu jauh
	var distance_x = global_position.x - start_position.x
	if abs(distance_x) > swim_range:
		facing_right = distance_x < 0
		_update_flip()

func _update_flip() -> void:
	var anim = $AnimatedSprite2D
	if anim:
		# Flip berdasarkan arah hadap dan arah default sprite
		if default_faces_right:
			anim.scale.x = 1 if facing_right else -1
		else:
			anim.scale.x = -1 if facing_right else 1
