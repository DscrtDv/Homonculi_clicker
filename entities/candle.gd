extends AnimatedSprite2D

func _ready():
	play("default")
	
	var candles = get_tree().get_nodes_in_group("Candle")

	# Create a Line2D node to draw lines
	var line = Line2D.new()
	add_child(line)

	# Configure the line properties
	line.width = 10.0
	line.default_color = Color(1, 1, 1)  # White color

	# Draw lines between each pair of candle nodes
	for i in range(candles.size()):
		for j in range(i + 1, candles.size()):
			var candle1 = candles[i]
			var candle2 = candles[j]
			line.add_point(candle1.global_position)
			line.add_point(candle2.global_position)

#func _process(delta: float) -> void:
	
