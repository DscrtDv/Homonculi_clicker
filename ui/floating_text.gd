extends Label

@onready var game_data : Data = load("res://data/Data.tres")
@onready var cursor_data : Entity = load("res://data/cursor.tres")
@export var float_distance := 50.0
@export var float_time := 1.0

func _ready():
	text = "+" + str(cursor_data.click_amount)
	modulate.a = 1.0
	z_index = game_data.zindex["UI"]
	scale = Vector2(0.8, 0.8)

	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - float_distance, float_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, float_time)
	tween.parallel().tween_property(self, "scale", Vector2(1.2, 1.2), float_time / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.connect("finished", Callable(self, "_on_tween_finished"))

func _on_tween_finished():
	queue_free()
