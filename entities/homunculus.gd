extends AnimatedSprite2D

@onready var game_data 		: Data 			= load("res://data/Data.tres")
@onready var clicker_data 	: Entity 		= game_data.clickers
@onready var tent_data 		: Entity 		= game_data.tentacles
@onready var candle_data	: Entity		= game_data.candles
@onready var floating_text	: PackedScene 	= game_data.floating_text

@onready var score 		= game_data.inventory.essence
@onready var max_score 	= game_data.phases_data.max_score[game_data.phase_index]
var scale_tween: Tween 	= null
var position_tween: Tween = null

@onready var timer 			= $RandomTimer
@onready var anim_timer		= $AnimationTimer
@onready var click_timer 	= $ClickTimer
@onready var target 		= $Area2D/CollisionShape2D
@onready var radius 		= game_data.phases_data.hm_rad[game_data.phase_index]
@onready var viewport_rect : Vector2 = get_viewport_rect().size

var mouse_in 				= false

signal clicked
signal phase_switch

func _ready() -> void:
	load_sprite()
	animation = "open_eye"
	frame = 0
	start_animation_timer()
	click_timer.wait_time = 1.0 / 4
	global_position.x = viewport_rect.x / 2
	global_position.y = (viewport_rect.y / 6) * 5 

func load_sprite():
	if game_data.phase <= game_data.max_phase:
		radius = game_data.phases_data.hm_rad[game_data.phase_index]
		target.shape.radius = radius
		# if game_data.phases_data.hm_sprite[game_data.phase_index]:
		# print("Loading sprite for phase: ", game_data.phase, " with index: ", game_data.phase_index, " path: ", game_data.phases_data.hm_sprite[game_data.phase_index])
		var curent_sframe = load(game_data.phases_data.hm_sprite[game_data.phase_index])
		sprite_frames = curent_sframe
		z_index = game_data.zindex["homunculus"]

func phase_check():
	if (score >= max_score) and game_data.phase <= game_data.max_phase:
		scale = Vector2(1.0, 1.0)
		game_data.phase += 1
		game_data.phase_index += 1
		load_sprite()
		phase_shift_anim()
		emit_signal("phase_switch")

func update_score():
	score 		= game_data.inventory.essence
	max_score 	= game_data.phases_data.max_score[game_data.phase_index]


#//------------------------------ INPUT ---------------------------//

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and mouse_in:
		click_timer.start()
	elif event.is_action_released("left_click") and mouse_in:
		if !click_timer.is_stopped():
			click_timer.stop()

func _mouse_entered() -> void:
	mouse_in = true

func _mouse_exited() -> void:
	mouse_in = false
	if !click_timer.is_stopped():
		click_timer.stop()

func click():
	emit_signal("clicked", self)
	var click_text = floating_text.instantiate()
	click_text.position = Vector2(0,0)
	add_child(click_text)

func _on_click_timer_timeout() -> void:
	click()


#//------------------------------ ANIMATION ---------------------------//

func score_to_scale():
	update_score()
	var target_scale_factor = lerp(1.0, 2.0, float(score) / float(max_score))
	var target_scale = Vector2(target_scale_factor, target_scale_factor)

	if scale_tween and scale_tween.is_running():
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", target_scale, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

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
			phase_position(4) # Adjust Y position for phase 2
		3:
			phase_position(3)
			pass
		4:
			pass
	start_animation_timer()

func phase_position( position_factor : float) -> void:
	if position_tween and position_tween.is_running():
		position_tween.kill()	
	position_tween = create_tween()
	position_tween.tween_property(self, "global_position", Vector2(global_position.x, (viewport_rect.y / 6) * position_factor), 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	position_tween.tween_callback(Callable(position_tween, "kill"))

#//------------------------------ BLINK ------------------------------//

func start_random_timer():
	var random_interval = randf_range(2.0, 10.0)
	timer.start(random_interval)
	
func _timer_timeout() -> void:
	play("blink")
	start_random_timer()

func _on_animation_finished() -> void:
	pass
	# if animation == "blink":
	# 	play("default")

func _on_ressource_ui_essence_update() -> void:
	phase_check()
	update_score()
	score_to_scale()
	
