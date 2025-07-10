extends Node2D

@onready var homunculus: Node2D = get_parent().get_node("Homunculus")


func _ready() -> void:
	print("Spawn Anchor Ready: HML: ", homunculus.position, " | Global: ", homunculus.global_position)
	global_position = get_viewport_rect().size * 0.5
	z_index = homunculus.z_index
