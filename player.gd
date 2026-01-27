extends CharacterBody2D

const KECEPATAN = 2000
var state: State
var states = {}
var vel = Vector2.ZERO
var arah_terakhir = Vector2.RIGHT
var can_move: bool = true

# Pickup system
var nearby_trash: Array = []

func _ready():
	# load states
	states["idle"] = load("res://states/IdleState.gd").new()
	states["jalan"] = load("res://states/JalanState.gd").new()
	states["serang"] = load("res://states/SerangState.gd").new()

	# kasih referensi player ke setiap state
	for s in states.values():
		s.player = self

	change_state("idle")
	
	# Connect ke DialogueManager signals
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
func get_animasi():
	return $AnimatedSprite2D
	
func change_state(new_state):
	if state:
		state.exit()
	if states.has(new_state):
		state = states[new_state]
		state.enter()

func _input(event):
	if can_move and not is_picking_up:
		state.handle_input(event)
		
		# M1 - pickup animation biasa (kapanpun)
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				play_pickup_animation_only()
		
		# F key - pickup sampah (jika ada sampah nearby)
		if event.is_action_pressed("pickup"):
			try_pickup_trash()

func _process(delta):
	if can_move and not is_picking_up:
		state.update(delta)

func _physics_process(delta):
	if can_move and not is_picking_up:
		state.physics_update(delta)
		move_and_slide()
	else:
		velocity = Vector2.ZERO

# M1 - hanya play animasi pickup sekali (bisa sambil jalan)
func play_pickup_animation_only():
	var anim = get_animasi()
	var pickup_anim = get_pickup_animation()
	anim.play(pickup_anim)

# F - pickup sampah sekali (bisa sambil jalan, langsung ambil)
func try_pickup_trash():
	if nearby_trash.size() > 0 and GameManager.quest_active:
		var anim = get_animasi()
		var pickup_anim = get_pickup_animation()
		anim.play(pickup_anim)
		
		# Langsung collect trash
		var trash = nearby_trash[0]
		if is_instance_valid(trash):
			GameManager.collect_trash()
			trash.queue_free()
			nearby_trash.erase(trash)
			print("[Player] Picked up trash!")

func get_pickup_animation() -> String:
	var anim = get_animasi()
	
	# Choose pickup animation based on last direction
	# Gunakan scale.x untuk flip, bukan flip_h (lebih konsisten)
	if arah_terakhir == Vector2.UP:
		anim.scale.x = 1
		return "pickup_atas"
	elif arah_terakhir == Vector2.DOWN:
		anim.scale.x = 1
		return "pickup_depan"
	elif arah_terakhir == Vector2.LEFT:
		anim.scale.x = -1  # Flip untuk kiri
		return "pickup_kanan"
	elif arah_terakhir == Vector2.RIGHT:
		anim.scale.x = 1
		return "pickup_kanan"
	else:
		anim.scale.x = 1
		return "pickup_depan"


func register_nearby_trash(trash: Node):
	if not nearby_trash.has(trash):
		nearby_trash.append(trash)

func unregister_nearby_trash(trash: Node):
	nearby_trash.erase(trash)

func _on_dialogue_started(_resource) -> void:
	can_move = false
	velocity = Vector2.ZERO
	change_state("idle")
	print("[Player] Dialogue started - movement disabled")

func _on_dialogue_ended(_resource) -> void:
	can_move = true
	print("[Player] Dialogue ended - movement enabled")
