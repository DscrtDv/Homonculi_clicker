extends AnimatedSprite2D

@onready var game_data : Data = load("res://data/Data.tres")

var target: Area2D
var target_shape : CollisionShape2D
var radius: float = 100.0
var speed: float = 1.0

func _ready() -> void:
	target = get_parent().get_node("Area2D")
	target_shape = target.get_node("CollisionShape2D")
	radius = target_shape.shape.radius
	play("default")
	
	match game_data.phase:
		3:
			scale *= 2.0
