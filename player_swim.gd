extends CharacterBody2D

# Player Swimming Controller
# Smooth 360 degree movement underwater

const SPEED = 150.0
const ACCELERATION = 400.0
const FRICTION = 300.0

# State
var input_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.RIGHT

# Repair/Interact system
var nearby_coral: Array = []

func _ready() -> void:
	var anim = get_animasi()
	if anim:
		anim.play("swim_idle")

func get_animasi():
	return $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Get input direction (WASD / Arrow keys)
	input_direction = Vector2.ZERO
	input_direction.x = Input.get_axis("ui_left", "ui_right")
	input_direction.y = Input.get_axis("ui_up", "ui_down")
	
	# Normalize untuk 360 degree movement yang konsisten
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
		facing_direction = input_direction
		
		# Smooth acceleration
		velocity = velocity.move_toward(input_direction * SPEED, ACCELERATION * delta)
		
		# Update animation dan rotation
		update_swim_animation()
	else:
		# Smooth deceleration (friction in water)
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
		# Idle animation saat berhenti
		var anim = get_animasi()
		if anim and velocity.length() < 10:
			anim.play("swim_idle")
	
	# Move
	move_and_slide()
	
	# Rotate sprite to face movement direction
	update_sprite_rotation()

func update_swim_animation() -> void:
	var anim = get_animasi()
	if not anim:
		return
	
	# Play swimming animation
	if anim.animation != "swim":
		anim.play("swim")

func update_sprite_rotation() -> void:
	var anim = get_animasi()
	if not anim:
		return
	
	# Rotate sprite berdasarkan arah gerak
	if velocity.length() > 10:
		var angle = facing_direction.angle()
		
		# Flip horizontal jika menghadap kiri
		if facing_direction.x < 0:
			anim.scale.x = -1
			# Adjust rotation untuk sprite yang di-flip
			anim.rotation = -angle - PI
		else:
			anim.scale.x = 1
			anim.rotation = angle

func _input(event: InputEvent) -> void:
	# F key - repair coral
	if event.is_action_pressed("pickup"):
		try_repair_coral()
	
	# M1 - repair animation (hanya jika menghadap horizontal)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var facing_horizontal = abs(facing_direction.x) > abs(facing_direction.y)
			if facing_horizontal:
				play_repair_animation()

func play_repair_animation() -> void:
	var anim = get_animasi()
	if not anim:
		return
	
	# Pastikan tidak loop
	var frames = anim.sprite_frames
	if frames and frames.has_animation("repair"):
		frames.set_animation_loop("repair", false)
		anim.stop()
		anim.play("repair")
	else:
		# Fallback ke swim jika tidak ada animasi repair
		anim.play("swim")

func try_repair_coral() -> void:
	if nearby_coral.size() > 0:
		var coral = nearby_coral[0]
		if is_instance_valid(coral) and coral.has_method("repair"):
			play_repair_animation()
			coral.repair()
			print("[PlayerSwim] Coral repaired!")

# Coral detection
func register_nearby_coral(coral: Node) -> void:
	if not nearby_coral.has(coral):
		nearby_coral.append(coral)
		print("[PlayerSwim] Coral nearby - Press F to repair")

func unregister_nearby_coral(coral: Node) -> void:
	nearby_coral.erase(coral)
