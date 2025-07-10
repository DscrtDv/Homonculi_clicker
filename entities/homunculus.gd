extends AnimatedSprite2D

@onready var game_data 		: Data 			= load("res://data/Data.tres")
@onready var clicker_data 	: Entity 		= game_data.clickers
@onready var tent_data 		: Entity 		= game_data.tentacles
@onready var candle_data	: Entity		= game_data.candles
@onready var floating_text	: PackedScene 	= game_data.floating_text

@onready var score 		= game_data.inventory.essence
@onready var max_score 	= game_data.phases_data.max_score[game_data.phase_index]
var scale_tween: Tween 	= null

@onready var timer 			= $RandomTimer
@onready var anim_timer		= $AnimationTimer
@onready var target 		= $Area2D/CollisionShape2D
@onready var radius 		= game_data.phases_data.hm_rad[game_data.phase_index]

var mouse_in 				= false

signal clicked
signal phase_switch

func _ready() -> void:
	load_sprite()
	animation = "open_eye"
	frame = 0
	start_animation_timer()
	init_floating_animation()
	global_position = get_viewport_rect().size * 0.5
	

func load_sprite():
	if game_data.phase <= game_data.max_phase:
		radius = game_data.phases_data.hm_rad[game_data.phase_index]
		target.shape.radius = radius
		var curent_sframe = load(game_data.phases_data.hm_sprite[game_data.phase_index])
		sprite_frames = curent_sframe
		z_index = game_data.zindex["homunculus"]
		print(z_index)

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

#//------------------------------ INPUT ---------------------------//

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and mouse_in:
		emit_signal("clicked", self)
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
			pass
			# var clickers = get_tree().get_nodes_in_group("Clicker")
			# for clicker in clickers:
			# 	clicker.scale *= 2
			# 	clicker.current_scale = Vector2(2.0, 2.0)
			# var tents = get_tree().get_nodes_in_group("Tentacle")
			# for tent in tents:
			# 	tent.scale *= 2
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
