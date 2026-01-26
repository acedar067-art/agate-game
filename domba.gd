extends Node2D

@export var speed: float = 20.0
@export var wander_range: float = 80.0

var is_walking: bool = false
var walk_direction: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO
var state_timer: float = 0.0

func _ready() -> void:
	start_position = position
	state_timer = randf_range(2.0, 4.0)

func _process(delta: float) -> void:
	state_timer -= delta
	
	if state_timer <= 0:
		is_walking = not is_walking
		if is_walking:
			state_timer = randf_range(1.0, 2.0)
			walk_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		else:
			state_timer = randf_range(2.0, 4.0)
	
	if is_walking:
		position += walk_direction * speed * delta
		if position.distance_to(start_position) > wander_range:
			walk_direction = (start_position - position).normalized()
	
	var anim = find_child("AnimatedSprite2D", true, false)
	if anim:
		if walk_direction.x < 0:
			anim.flip_h = false
		elif walk_direction.x > 0:
			anim.flip_h = true
