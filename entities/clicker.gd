extends AnimatedSprite2D
signal clicker_clicked

@onready var game_data 		: Data 		= load("res://data/Data.tres")
@onready var clicker_data 	: Entity 	= game_data.clickers

@export var trans_time : float = 0.2
@onready var index = clicker_data.amount

var current_scale = Vector2(1.0, 1.0)

func _ready() -> void:
	play("default")
	match game_data.phase:
		3:
			scale *= 2.0
			current_scale = scale

func _on_timer_timeout() -> void:
	emit_signal("clicker_clicked")
	click_animation()

func click_animation():
	play("click")
	var tween: Tween = create_tween()
	var scale_max = current_scale * 1.2
	tween.tween_property(self, "scale", scale_max, trans_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate", Color(1, 0.5, 0.5), trans_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", current_scale, trans_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate", Color(1, 1, 1), trans_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func _on_animation_finished() -> void:
	if animation == "click":
		play("default")
