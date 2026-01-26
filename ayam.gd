extends Node2D

# Movement settings
@export var speed: float = 25.0
@export var wander_range: float = 100.0

# State
var is_walking: bool = false
var walk_direction: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO
var state_timer: float = 0.0

func _ready() -> void:
	start_position = position
	state_timer = randf_range(1.0, 3.0)

func _process(delta: float) -> void:
	state_timer -= delta
	
	if state_timer <= 0:
		# Toggle state
		is_walking = not is_walking
		
		if is_walking:
			# Start walking
			state_timer = randf_range(1.0, 2.5)
			walk_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		else:
			# Start idling
			state_timer = randf_range(1.0, 3.0)
	
	if is_walking:
		position += walk_direction * speed * delta
		
		# Check if too far from start
		if position.distance_to(start_position) > wander_range:
			walk_direction = (start_position - position).normalized()
	
	# Update sprite direction
	var anim = find_child("AnimatedSprite2D", true, false)
	if anim:
		if walk_direction.x < 0:
			anim.flip_h = false
		elif walk_direction.x > 0:
			anim.flip_h = true
