extends Node2D

@onready var clicker_data : Data = load("res://data/clicker.tres")
@onready var cursor_data : Data = load("res://data/cursor.tres")
@onready var inventory : Inventory = load("res://data/inventory.tres")
signal essence_updated
signal price_updated

var essence : int = 0
var blood 	: int = 0
var coal 	: int = 0
var gold 	: int = 0
var silver 	: int = 0

func update_price():
	update_essence(-clicker_data.add_price)
	clicker_data.add_price *= 1.2
	clicker_data.add_price = int(clicker_data.add_price)
	emit_signal("price_updated", clicker_data.add_price)

func update_essence(n : int):
	essence += n * inventory.multiplier
	emit_signal("essence_updated", n)

func _on_homunculus_clicked() -> void:
	update_essence(cursor_data.click_amount)

func _on_spawn_clicker() -> void:
	update_price()
