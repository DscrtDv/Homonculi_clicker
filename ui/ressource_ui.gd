extends Control

signal essence_update

@onready var game_data 		: Data 		= load("res://data/Data.tres")
@onready var cursor_data 	: Entity 	= game_data.cursor
@onready var clicker_data 	: Entity 	= game_data.clickers
@onready var tentacle_data	: Entity	= game_data.tentacles
@onready var inventory 		: Inventory = game_data.inventory

@onready var label 					= $Essence
@onready var ps_label				= $Ps

var prev_essence = 0
var essence_per_sec = 0

func _ready() -> void:
	update_essence()
	ps_label.text = str(essence_per_sec) + "/s"

func update_essence() -> void:
	var n : int = inventory.essence
	var formatted_string : String = "%03d %03d %03d" % [n / 1000000, (n / 1000) % 1000, n % 1000]
	label.text = formatted_string
	emit_signal("essence_update")

func _on_homunculus_clicked ( node ) -> void:
	var temp_amount : int = 0
	match node.name:
		"Clicker":
			temp_amount = clicker_data.click_amount
		"Homunculus":
			temp_amount = cursor_data.click_amount
		"Candle":
			temp_amount = game_data.candles.click_amount
	inventory.essence += temp_amount * inventory.multiplier
	update_essence()

func _on_timer_timeout() -> void:
	var temp = inventory.essence - prev_essence
	prev_essence = inventory.essence
	if (temp >= 0):
		ps_label.text = str(temp) + "/s"
	if inventory.n_tentacule > 0:
		inventory.essence += inventory.n_tentacule * tentacle_data.click_amount
		update_essence()
