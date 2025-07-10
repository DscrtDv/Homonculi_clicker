extends Camera2D

@export var zoom_speed := 0.1
@export var min_zoom := 0.1
@export var max_zoom := 5.0
var zoom_tween: Tween

func _ready():
	set_pos()

func set_pos():
	global_position =$"../Homunculus".global_position

#func _unhandled_input(event):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#zoom_camera(zoom_speed)
		#elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#zoom_camera(-zoom_speed)
#
#func zoom_camera(delta_zoom):
	#var target_zoom = zoom + Vector2(delta_zoom, delta_zoom)
	#target_zoom.x = clamp(target_zoom.x, min_zoom, max_zoom)
	#target_zoom.y = clamp(target_zoom.y, min_zoom, max_zoom)
#
	#if zoom_tween and zoom_tween.is_running():
		#zoom_tween.kill()
#
	#zoom_tween = create_tween()
	#zoom_tween.tween_property(self, "zoom", target_zoom, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
