extends Node

# Quest State
var quest_active: bool = false
var quest_completed: bool = false
var quest_failed: bool = false
var quest_times_completed: int = 0

# Trash Collection
var trash_count: int = 0
var target_trash: int = 10

# Timer
var quest_time_limit: float = 180.0  # 3 minutes default
var time_remaining: float = 0.0
var timer_active: bool = false

# Score
var score: int = 0

# Signals
signal quest_started(spawn_count: int)
signal trash_collected(new_count: int)
signal quest_completed_signal
signal quest_failed_signal
signal timer_updated(time_left: float)

func _process(delta: float) -> void:
	if timer_active and quest_active:
		time_remaining -= delta
		timer_updated.emit(time_remaining)
		
		if time_remaining <= 0:
			fail_quest()

func start_quest() -> void:
	quest_active = true
	quest_completed = false
	quest_failed = false
	trash_count = 0
	
	# Determine target based on how many times completed
	if quest_times_completed == 0:
		target_trash = 10
		quest_time_limit = 180.0  # 3 minutes for first quest
	else:
		target_trash = 20
		quest_time_limit = 300.0  # 5 minutes for second quest
	
	# Start timer
	time_remaining = quest_time_limit
	timer_active = true
	
	# Emit signal with spawn count
	quest_started.emit(20)
	print("[GameManager] Quest started! Target: ", target_trash, " Time: ", quest_time_limit)

func collect_trash() -> void:
	if quest_active and not quest_completed and not quest_failed and trash_count < target_trash:
		trash_count += 1
		trash_collected.emit(trash_count)
		print("[GameManager] Trash collected: ", trash_count, "/", target_trash)

func complete_quest() -> void:
	if quest_active and trash_count >= target_trash:
		quest_completed = true
		quest_active = false
		timer_active = false
		score += 100
		quest_times_completed += 1
		quest_completed_signal.emit()
		print("[GameManager] Quest completed! Score: ", score)

func fail_quest() -> void:
	quest_failed = true
	quest_active = false
	timer_active = false
	quest_failed_signal.emit()
	print("[GameManager] Quest failed! Time ran out.")

func reset_quest() -> void:
	quest_active = false
	quest_completed = false
	quest_failed = false
	trash_count = 0
	timer_active = false
	print("[GameManager] Quest reset")

func can_complete_quest() -> bool:
	return quest_active and trash_count >= target_trash

func can_take_new_quest() -> bool:
	return not quest_active and not quest_failed and quest_times_completed < 2

func can_retry_quest() -> bool:
	return quest_failed

func all_quests_done() -> bool:
	return quest_times_completed >= 2

func get_formatted_time() -> String:
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	return "%d:%02d" % [minutes, seconds]
