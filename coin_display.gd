extends CanvasLayer

# Coin Display HUD
# Shows current coin count in top-right corner

@onready var coin_label: Label = $CoinLabel
@onready var coin_icon: TextureRect = $CoinIcon # optional

var coin_count: int = 0

func _ready():
	# Connect to GameManager coin updates
	if GameManager.has_signal("coins_updated"):
		GameManager.coins_updated.connect(_on_coins_updated)
	
	# Load saved coins
	coin_count = GameManager.coins
	update_display()

func _on_coins_updated(new_amount: int):
	coin_count = new_amount
	update_display()
	
	# Optional: Animate coin gain
	if coin_label:
		animate_coin_gain()

func update_display():
	if coin_label:
		coin_label.text = str(coin_count)

func animate_coin_gain():
	# Simple scale animation
	var tween = create_tween()
	tween.tween_property(coin_label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(coin_label, "scale", Vector2(1.0, 1.0), 0.1)
