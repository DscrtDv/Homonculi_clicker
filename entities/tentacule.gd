extends AnimatedSprite2D

@onready var game_data : Data = load("res://data/Data.tres")

func _ready() -> void:
	play("default")
	
	var final_scale := Vector2.ONE
	# match game_data.phase:
	# 	3:
	# 		final_scale *= 2.0

	# Start with zero scale (or very small to avoid invisible errors)
	scale = Vector2.ZERO
	
	# Create tween to grow
	var tween = create_tween()
	tween.tween_property(self, "scale", final_scale, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Optionally wait before freeing, for example after the grow animation
	tween.tween_callback(Callable(tween, "queue_free"))
