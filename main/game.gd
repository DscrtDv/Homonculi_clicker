extends Node2D

@onready var game_data 		: Data 			= load("res://data/Data.tres")
@onready var clicker_data 	: Entity 		= game_data.clickers
@onready var tent_data 		: Entity 		= game_data.tentacles
@onready var candle_data	: Entity		= game_data.candles

@onready var homunculus     : AnimatedSprite2D 	= $Homunculus
@onready var clicker_timer  : Timer 			= $ClickerTimer
@onready var ressource_ui   : Control 			= $UI/RessourceUi
@onready var upgrade_ui		: Control 			= $UI/UpgradeUI

var clickers : Array = []
var clicker_rotation_speed 	= .2
var current_angle_clickers	= 0

var tentacles : Array = []
var tentacle_rotation_speed = -0.1
var current_angle_tentacles = 0

var candles : Array = []
var candle_rotation_speed = 0.05
var current_angle_candles = 0

signal clicker_spawned(amount : int)

func _process(delta: float) -> void:
	current_angle_clickers += clicker_rotation_speed * delta
	current_angle_tentacles += tentacle_rotation_speed * delta
	current_angle_candles += candle_rotation_speed * delta

	update_entity(clickers, clicker_data, current_angle_clickers, 30, 0.05, false)
	update_entity(tentacles, tent_data, current_angle_tentacles, 28, 0.05, true)
	update_candles()

# ------------ SIGNALS SPAWN ------------
func _on_spawn_clicker() -> void:
	var clicker = clicker_data.scene.instantiate()
	clicker.connect("clicker_clicked", Callable(ressource_ui, "_on_homunculus_clicked"))
	homunculus.add_child(clicker)
	clicker.z_index = game_data.zindex["clicker"]
	emit_signal("clicker_spawned", clicker_data.amount)
	clickers = get_tree().get_nodes_in_group("Clicker")


func _on_spawn_tentacle() -> void:
	var tentacle = tent_data.scene.instantiate()
	homunculus.add_child(tentacle)
	tentacle.z_index = game_data.zindex["tentacle"]
	tentacles = get_tree().get_nodes_in_group("Tentacle")

func _on_spawn_candle() -> void:
	var candle = candle_data.scene.instantiate()
	#connectsig
	homunculus.add_child(candle)
	candle.z_index = game_data.zindex["candle"]
	candles = get_tree().get_nodes_in_group("Candle")

func update_candles():
	if candles.size() == 0:
		return
	for child in homunculus.get_children():
		if child is Line2D:
			child.queue_free()
	for i in range(candle_data.amount):
		var tween := create_tween()
		var angle = i * (2 * PI / candle_data.amount) + current_angle_candles
		var mod = 160
		if (candle_data.amount >= 20):
			mod = 72
		var candle_radius = homunculus.radius + mod
		var x = candle_radius * cos(angle)
		var y = candle_radius * sin(angle)
		
		tween.tween_property(candles[i], "position", Vector2(x, y), 0.5)
		
	for i in range(candles.size()):
		var line = Line2D.new()
		line.width = 2.0
		line.z_index = game_data.zindex["lines"]
		line.default_color = Color(1, 0, 0)
		
		if i < candles.size() - 1:
			# Draw line from current clicker to the next one
			line.add_point(candles[i].position)
			line.add_point(candles[i + 1].position)
		else:
			# Draw line from last clicker back to the first
			line.add_point(candles[i].position)
			line.add_point(candles[0].position)
		
		homunculus.add_child(line)
	
	if (candles.size() >= 5):
		for i in range(candles.size()):
			var line = Line2D.new()
			line.width = 2.0
			line.default_color = Color(1, 0, 0)  # Using red color for distinction
			line.z_index = game_data.zindex["lines"]
			# Calculate the index for the second clicker in the pair
			var next_index = (i + 2) % candles.size()

			# Draw line from current clicker to the one two positions ahead
			line.add_point(candles[i].position)
			line.add_point(candles[next_index].position)

			homunculus.add_child(line)

# ------------ CIRCULAR ANIM ------------
# Linear interpolation way 
# Sets the entities in a circular pattern around the homunculus
func update_entity ( nodes : Array, node_data : Entity, current_angle : float, 
					radius_mod : int, damping : float, face_center : bool ) -> void:
	if nodes.is_empty():
		return
	for i in range(node_data.amount):
		var node = nodes[i]
		var angle = i * (2 * PI / node_data.amount) + current_angle
		var node_radius = homunculus.radius + radius_mod
		var target_pos = Vector2(node_radius * cos(angle), node_radius * sin(angle))
		
		node.position = node.position.lerp(target_pos, damping)
		
		if face_center:
			var desired_angle = angle + PI / 2
			node.rotation = lerp_angle(node.rotation, desired_angle, damping)
