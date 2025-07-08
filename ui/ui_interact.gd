extends TextureRect

signal ui_clicked
var mouse_in : bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and mouse_in:
		emit_signal("ui_clicked", self)

func _on_mouse_entered() -> void:
	mouse_in = true
	scale = Vector2(1.25,1.25)

func _on_mouse_exited() -> void:
	mouse_in = false
	scale = Vector2(1.0, 1.0)
