extends Timer

@onready var game_data 		: Data 		= load("res://data/Data.tres")
@onready var clicker_data 	: Entity 	= game_data.clickers


var index 		: int = 0
var clickers 	: Array

# Set timer wait_time to the click interval from clicker_data if its the first clicker
# otherwise, set it to the click interval divided by the number of clickers
func _on_clicker_spawn() -> void:
	if is_stopped():
		wait_time = clicker_data.click_interval
		start()
	else:
		wait_time = clicker_data.click_interval / clicker_data.amount
	update_clicker_group()

func update_clicker_group():
	clickers = get_tree().get_nodes_in_group("Clicker")

# calls the _on_timer_timeout method of each clicker in the group which emits the clicker_clicked signal
func _on_timeout() -> void:
	for i in range(clickers.size()):
		if i == index:
			clickers[i]._on_timer_timeout()
	if index == clicker_data.amount - 1:
		index = 0
	else:
		index += 1

# updates the wait_time of the timer when clicker_speed is upgraded
func _on_upgrade_clicker() -> void:
	wait_time = clicker_data.click_interval / clicker_data.amount
