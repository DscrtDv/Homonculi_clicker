extends Timer

@onready var game_data 		: Data 		= load("res://data/Data.tres")
@onready var clicker_data 	: Entity 	= game_data.clickers

var index : int = 0
var clickers : Array

signal clicker_clicked

func _on_clicker_spawn() -> void:
	if is_stopped():
		wait_time = clicker_data.click_interval
		start()
	else:
		wait_time = clicker_data.click_interval / clicker_data.amount
	#print(wait_time, " | ",is_stopped())
	update_clicker_group()

func update_clicker_group():
	clickers = get_tree().get_nodes_in_group("Clicker")

func _on_timeout() -> void:
	for i in range(clickers.size()):
		if i == index:
			clickers[i]._on_timer_timeout()
	if index == clicker_data.amount - 1:
		index = 0
	else:
		index += 1
		

func _on_upgrade_clicker() -> void:
	wait_time = clicker_data.click_interval / clicker_data.amount
