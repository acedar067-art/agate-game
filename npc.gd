extends CharacterBody2D

const speed = 30
var current_state  = IDLE

var dir = Vector2.RIGHT
var start_pos

var is_roaming = true
var is_chatting = false

var player
var player_in_chat_zone
enum {
	IDLE,
	NEW_DIR,
	MOVE
}



func _ready():
	randomize()
	start_pos = position

func _process(delta):
	if current_state == IDLE or current_state == NEW_DIR:
		$AnimatedSprite2D.play("idle")
	elif current_state == MOVE and !is_chatting:
		if dir.x == -1:
			$AnimatedSprite2D.play("walk_w")
		if dir.x == 1:
			$AnimatedSprite2D.play("walk_e")
		if dir.y == -1:
			$AnimatedSprite2D.play("walk_n")
		if dir.y == 1:
			$AnimatedSprite2D.play("walk_s")

	if is_roaming and !is_chatting:
		match current_state:
			IDLE:
				pass
			NEW_DIR:
				dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
			MOVE:
				move(delta)

func choose(array):
	array.shuffle()
	return array.front()

func move(delta):
	if !is_chatting:
		velocity = dir * speed
		move_and_slide()



func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("Player"):
		player = body
		player_in_chat_zone = true
		is_chatting = true


func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("Player"):
		player_in_chat_zone = false
		is_chatting = false


func _on_timer_timeout() -> void:
	# Cycle through states appropriately
	if current_state == IDLE:
		current_state = NEW_DIR
	elif current_state == NEW_DIR:
		current_state = MOVE
	elif current_state == MOVE:
		current_state = IDLE

	# Set a random wait time for the next state change
	$Timer.wait_time = choose([0.5, 1, 1.5, 2.0])
