extends ParallaxBackground

@export var speed_step : float = 0.1
@onready var layers := []

func _ready() -> void:
	var children = get_children()
	for i in range(children.size()):
		if children[i] is ParallaxLayer:
			var layer_data = {
				"node": children[i],
				"speed": (i * speed_step),
			}
			layers.append(layer_data)
	print("Layers initialized: ", layers.size())

func _process(delta: float) -> void:
	for layer_data in layers:
		layer_data["node"].rotation_degrees += layer_data["speed"] * delta
