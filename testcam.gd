extends Camera2D

@export var amplitude: Vector2 = Vector2(20, 10)
@export var speed: Vector2 = Vector2(1, 1.5)

@export var mouse_follow_strength: float = 0.05  # How much camera moves toward mouse
@export var mouse_max_offset: Vector2 = Vector2(50, 30)  # Maximum offset in pixels

var time := 0.0
var base_position := Vector2.ZERO



func _ready():

	base_position = global_position

func _process(delta):
	time += delta

	# Base floating offset
	var offset_x = sin(time * speed.x) * amplitude.x
	var offset_y = cos(time * speed.y) * amplitude.y
	var float_offset = Vector2(offset_x, offset_y)

	# Mouse-follow offset
	var viewport_size = get_viewport().size
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_center = viewport_size * 0.5

	var mouse_offset = (mouse_pos - screen_center) * mouse_follow_strength

	# Clamp offset to max
	mouse_offset.x = clamp(mouse_offset.x, -mouse_max_offset.x, mouse_max_offset.x)
	mouse_offset.y = clamp(mouse_offset.y, -mouse_max_offset.y, mouse_max_offset.y)

	# Apply final position
	global_position = base_position + float_offset + mouse_offset
