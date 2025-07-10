extends AnimatedSprite2D

@onready var game_data 		: Data 			= load("res://data/Data.tres")
@onready var clicker_data 	: Entity 		= game_data.clickers
@onready var tent_data 		: Entity 		= game_data.tentacles
@onready var candle_data	: Entity		= game_data.candles
@onready var floating_text	: PackedScene 	= game_data.floating_text

@onready var line_shader	: Shader		= load("res://Shaders/glow.gdshader")


@onready var score 		= game_data.inventory.essence
@onready var max_score 	= game_data.phases_data.max_score[game_data.phase_index]
var scale_tween: Tween = null

@export var clicker_timer : Timer
@onready var timer 			= $RandomTimer
@onready var anim_timer		= $AnimationTimer
@onready var target 		= $Area2D/CollisionShape2D
@onready var radius 		= game_data.phases_data.hm_rad[game_data.phase_index]
@export var rotation_speed 	= .2

var rotation_speed_clicker = .2
var rotation_speed_tent = -0.1
var rotation_speed_candle = 0.05

var current_angle_tents 	= 0
var current_angle_clickers	= 0
var current_angle_candles	= 0

var mouse_in = false
signal clicked
signal clicker_clicked
signal clicker_spawned
signal phase_switch

func _ready() -> void:
	load_sprite()
	animation = "open_eye"
	frame = 0
	start_animation_timer()
	init_floating_animation()
	global_position = get_viewport_rect().size * 0.5

func _process(delta: float) -> void:
	current_angle_clickers += rotation_speed * delta
	current_angle_tents += rotation_speed_tent * delta
	current_angle_candles += rotation_speed_candle * delta
	update_clickers()
	update_tentacles()
	update_candles()

func load_sprite():
	if game_data.phase <= game_data.max_phase:
		radius 	= game_data.phases_data.hm_rad[game_data.phase_index]
		target.shape.radius = radius
		var curent_sframe = load(game_data.phases_data.hm_sprite[game_data.phase_index])
		sprite_frames = curent_sframe

func phase_check():
	if (score >= max_score) and game_data.phase != game_data.max_phase:
		scale = Vector2(1.0, 1.0)
		game_data.phase += 1
		game_data.phase_index += 1
		load_sprite()
		phase_shift_anim();
		emit_signal("phase_switch")

func update_score():
	score 		= game_data.inventory.essence
	max_score 	= game_data.phases_data.max_score[game_data.phase_index]

#//------------------------------ CLICKERS ---------------------------//

func _on_spawn_clicker() -> void:
	var clicker = clicker_data.scene.instantiate()
	clicker.connect("clicker_clicked", Callable(self, "_on_clicker_clicked"))
	add_child(clicker)
	emit_signal("clicker_spawned", clicker_data.amount)
	update_clickers()

func _on_spawn_tentacle() -> void:
	var tent = tent_data.scene.instantiate()
	add_child(tent)
	update_tentacles()

func _on_spawn_candle() -> void:
	var candle = candle_data.scene.instantiate()
	#connectsig
	add_child(candle)
	update_candles()

func update_candles():
	var candles = get_tree().get_nodes_in_group("Candle")
	for child in get_children():
		if child is Line2D:
			child.queue_free()
	for i in range(candle_data.amount):
		var tween := create_tween()
		var angle = i * (2 * PI / candle_data.amount) + current_angle_candles
		var face_center = angle + PI
		var mod = 160
		if (candle_data.amount >= 20):
			mod = 72
		var candle_radius = radius + mod
		var x = candle_radius * cos(angle)
		var y = candle_radius * sin(angle)
		
		tween.tween_property(candles[i], "position", Vector2(x, y), 0.5)
		
	for i in range(candles.size()):
		var line = Line2D.new()
		line.width = 2.0
		line.z_index = -5
		line.default_color = Color(1, 0, 0)
		
		if i < candles.size() - 1:
			# Draw line from current clicker to the next one
			line.add_point(candles[i].position)
			line.add_point(candles[i + 1].position)
		else:
			# Draw line from last clicker back to the first
			line.add_point(candles[i].position)
			line.add_point(candles[0].position)
		
		add_child(line)
	
	if (candles.size() >= 5):
		for i in range(candles.size()):
			var line = Line2D.new()
			line.width = 2.0
			line.default_color = Color(1, 0, 0)  # Using red color for distinction
			line.z_index = -5
			# Calculate the index for the second clicker in the pair
			var next_index = (i + 2) % candles.size()

			# Draw line from current clicker to the one two positions ahead
			line.add_point(candles[i].position)
			line.add_point(candles[next_index].position)

			add_child(line)

func update_tentacles():
	var tents = get_tree().get_nodes_in_group("Tentacle")
	for i in range(tent_data.amount):
		var tween := create_tween()
		var angle = i * (2 * PI / tent_data.amount) + current_angle_tents
		var face_center = angle + PI / 2
		var tent_radius = radius + 28
		var x = tent_radius * cos(angle)
		var y = tent_radius * sin(angle)
		tents[i].z_index = -1
		tween.tween_property(tents[i], "position", Vector2(x, y), 0.5)
		tween.parallel().tween_property(tents[i], "rotation", face_center, 0.5)
	

func update_clickers():
	var clickers = get_tree().get_nodes_in_group("Clicker")
	for child in get_children():
		if child is Line2D:
			child.queue_free()
	for i in range(clicker_data.amount):
		var tween := create_tween()
		var angle = i * (2 * PI / clicker_data.amount) + current_angle_clickers
		var face_center = angle + PI
		var mod = 30
		if (clicker_data.amount >= 20):
			mod = 72
		var clicker_radius = radius + mod
		var x = clicker_radius * cos(angle)
		var y = clicker_radius * sin(angle)
		
		tween.tween_property(clickers[i], "position", Vector2(x, y), 0.5)
		#tween.parallel().tween_property(clickers[i], "rotation", face_center, 0.5)

func _on_clicker_clicked():
	emit_signal("clicker_clicked")

#//------------------------------ INPUT ---------------------------//

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and mouse_in:
		emit_signal("clicked")
		var click_text = floating_text.instantiate()
		click_text.position = Vector2(0,0)
		add_child(click_text)

func _mouse_entered() -> void:
	mouse_in = true

func _mouse_exited() -> void:
	mouse_in = false

#//------------------------------ ANIMATION ---------------------------//

func score_to_scale():
	update_score()
	var target_scale_factor = lerp(1.0, 2.0, float(score) / float(max_score))
	var target_scale = Vector2(target_scale_factor, target_scale_factor)

	if scale_tween and scale_tween.is_running():
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", target_scale, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func init_floating_animation():
	var tween = create_tween()
	var float_height = 15
	var float_duration = 6.0
	tween.tween_property(self, "position:y", position.y - float_height, float_duration / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", position.y, float_duration / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()

func animate():
	var current_scale = scale
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", current_scale * 1.02, 0.05).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", scale, 0.05).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)

func start_animation_timer():
	if (!timer.is_stopped()):
		timer.stop()
	anim_timer.start()
	
func _on_animation_timer_timeout() -> void:
	play("open_eye")
	start_random_timer()
	
func phase_shift_anim():
	match game_data.phase:
		1:
			pass
		2:
			play("smile")
		3:
			var clickers = get_tree().get_nodes_in_group("Clicker")
			for clicker in clickers:
				clicker.scale *= 2
				clicker.current_scale = Vector2(2.0, 2.0)
			var tents = get_tree().get_nodes_in_group("Tentacle")
			for tent in tents:
				tent.scale *= 2
		4:
			play("default")
	start_animation_timer()

#//------------------------------ BLINK ------------------------------//

func start_random_timer():
	var random_interval = randf_range(2.0, 10.0)
	timer.start(random_interval)
	
func _timer_timeout() -> void:
	play("blink")
	start_random_timer()

func _on_animation_finished() -> void:
	if animation == "blink":
		play("default")

func _on_ressource_ui_essence_update() -> void:
	update_score()
	phase_check()
	score_to_scale()
