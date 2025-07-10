extends AnimatedSprite2D
signal clicker_clicked

@onready var game_data 		: Data 		= load("res://data/Data.tres")
@onready var clicker_data 	: Entity 	= game_data.clickers

@export var trans_time : float = 0.2
@onready var index = clicker_data.amount
@onready var parent = get_parent()

@onready var current_scale = scale

func _ready() -> void:
	play("default")
	# match game_data.phase:
	# 	3:
	# 		scale *= 2.0
	# 		current_scale = scale

func _on_timer_timeout() -> void:
	emit_signal("clicker_clicked", self)
	click_animation()

func click_animation():
	play("click")
	var tween: Tween = create_tween()
	var scale_max = current_scale * 1.2
	tween.tween_property(self, "scale", scale_max, trans_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate", Color(1, 0.5, 0.5), trans_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", current_scale, trans_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate", Color(1, 1, 1), trans_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	launch_circle_to_target(parent.position)

func _on_animation_finished() -> void:
	if animation == "click":
		play("default")

func launch_circle_to_target(target_pos: Vector2) -> void:
	var circle_texture = create_circle_texture(8, Color.BLACK)

	var circle_sprite := Sprite2D.new()
	circle_sprite.texture = circle_texture
	circle_sprite.position = global_position
	circle_sprite.z_index = game_data.zindex["fx"]  # Optional: make sure it appears on top

	get_tree().current_scene.add_child(circle_sprite)

	var tween := create_tween()
	tween.tween_property(circle_sprite, "global_position", target_pos, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(circle_sprite, "queue_free"))

func create_circle_texture(size: int, color: Color) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))  # Transparent background

	var center = Vector2(size / 2, size / 2)
	var radius = size / 2

	for x in range(size):
		for y in range(size):
			var pos = Vector2(x, y)
			if pos.distance_to(center) <= radius:
				image.set_pixel(x, y, color)

	var texture = ImageTexture.create_from_image(image)
	return texture
