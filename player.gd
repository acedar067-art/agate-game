extends CharacterBody2D

const KECEPATAN = 200
var state: State
var states = {}
var vel = Vector2.ZERO
var arah_terakhir = Vector2.RIGHT
var can_move: bool = true

# Pickup system
var nearby_trash: Array = []
var is_playing_pickup: bool = false  # Flag untuk mencegah spam M1

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
	
	# Connect animation finished signal untuk reset setelah pickup
	get_animasi().animation_finished.connect(_on_animation_finished)
	
func get_animasi():
	return $AnimatedSprite2D
	
func change_state(new_state):
	if state:
		state.exit()
	if states.has(new_state):
		state = states[new_state]
		state.enter()

func _input(event):
	if can_move:
		state.handle_input(event)
		
		# M1 - pickup animation (hanya jika menghadap KANAN atau KIRI)
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				# Cek apakah player menghadap kanan atau kiri
				var facing_horizontal = abs(arah_terakhir.x) > abs(arah_terakhir.y)
				if facing_horizontal:
					play_pickup_animation_only()
		
		# F key - pickup sampah (jika ada sampah nearby)
		if event.is_action_pressed("pickup"):
			try_pickup_trash()

func _process(delta):
	if can_move:
		state.update(delta)

func _physics_process(delta):
	if can_move:
		state.physics_update(delta)
		move_and_slide()
	else:
		velocity = Vector2.ZERO

# M1 - play animasi pickup sekali per klik (TIDAK loop, bisa berulang kali)
func play_pickup_animation_only():
	var anim = get_animasi()
	var pickup_anim = get_pickup_animation()
	
	# Pastikan animasi pickup tidak loop
	var frames = anim.sprite_frames
	if frames:
		frames.set_animation_loop(pickup_anim, false)
	
	# Play dari awal setiap kali M1 ditekan
	anim.stop()
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
	
	# Hanya pakai animasi kanan/kiri berdasarkan arah terakhir
	if arah_terakhir.x < 0:
		# LEFT - flip sprite
		anim.scale.x = -1
	else:
		# RIGHT (default)
		anim.scale.x = 1
	
	return "pickup_kanan"


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

# Reset flag setelah animasi pickup selesai
func _on_animation_finished():
	if is_playing_pickup:
		is_playing_pickup = false
		# Kembali ke animasi idle/jalan yang sesuai
		if velocity.length() > 0:
			change_state("jalan")
		else:
			change_state("idle")
