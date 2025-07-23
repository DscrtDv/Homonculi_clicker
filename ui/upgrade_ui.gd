extends Control

@onready var game_data 		: Data 		= load("res://data/Data.tres")
@onready var cursor_data 	: Entity 	= game_data.cursor
@onready var clicker_data 	: Entity 	= game_data.clickers
@onready var tentacle_data	: Entity	= game_data.tentacles
@onready var candle_data 	: Entity	= game_data.candles
@onready var inventory 		: Inventory = game_data.inventory

signal spawn_clicker
signal spawn_tentacle
signal spawn_candle
signal update_essence
signal upgrade_clicker

@onready var cursor = {
	"node": $VBoxContainer/CursorLVL,
	"label_price": $VBoxContainer/CursorLVL/Price,
	"label_amount": $VBoxContainer/CursorLVL/Level,
	"data": cursor_data,
	"phase": 1
}

@onready var clicker = {
	"node": $VBoxContainer/Clicker,
	"label_price": $VBoxContainer/Clicker/Price,
	"label_amount": $VBoxContainer/Clicker/Amount,
	"data": clicker_data,
	"phase": 1
}

@onready var clickerLvl = {
	"node": $VBoxContainer/ClickerLVL,
	"label_price": $VBoxContainer/ClickerLVL/Price,
	"label_lvl": $VBoxContainer/ClickerLVL/LVL,
	"phase": 2
}

@onready var tent = {
	"node": $VBoxContainer/Tent,
	"label_price": $VBoxContainer/Tent/Price,
	"label_lvl": $VBoxContainer/Tent/LVL,
	"data": tentacle_data,
	"phase": 2
}

@onready var tentLvl = {
	"node": $VBoxContainer/TentLVL, 
	"label_price": $VBoxContainer/TentLVL/Price,
	"label_lvl": $VBoxContainer/TentLVL/LVL,
	"data": tentacle_data,
	"phase": 3
}

@onready var candle = {
	"node": $VBoxContainer/Candle, 
	"label_price": $VBoxContainer/Candle/Price,
	"label_lvl": $VBoxContainer/Candle/LVL,
	"data": candle_data,
	"phase": 3
}

@onready var elems : Array = [cursor, clicker, clickerLvl, tent, tentLvl, candle]

func _ready() -> void:
	update_labels()
	for elem in elems:
		if elem.node:
			elem.node.visible = false
	set_phase_unlock()
	
func update_labels() -> void:
	clicker.label_amount.text 	= str(clicker.data.amount)
	clicker.label_price.text 	= str(clicker.data.add_price)
	
	clickerLvl.label_price.text = str(clicker.data.upgrade_price)
	clickerLvl.label_lvl.text 	= str(clicker.data.lvl)
	
	cursor.label_amount.text 	= str(cursor.data.lvl)
	cursor.label_price.text 	= str(cursor.data.upgrade_price)
	
	tent.label_price.text		= str(tent.data.add_price)
	tent.label_lvl.text 		= str(tent.data.amount)
	
	tentLvl.label_price.text	= str(tentLvl.data.upgrade_price)
	tentLvl.label_lvl.text 		= str(tentLvl.data.lvl)
	
	candle.label_price.text 	= str(candle.data.add_price)
	candle.label_lvl.text		= str(candle.data.amount)
	

func set_phase_unlock():
	for elem in elems:
		if elem.node and elem.phase:
			if elem.phase == game_data.phase:
				elem.node.visible = true

func _on_clicker_spawned(n : int) -> void:
	clicker.label_amount.text = str(n)

func _on_ressource_manager_price_updated(n) -> void:
	clicker.label_price.text = str(n)

func _on_ui_clicked(obj) -> void:
	match obj.name:
		"Clicker":
			if (inventory.essence >= clicker.data.add_price):
				inventory.essence -= clicker.data.add_price
				clicker.data.add_price = int(clicker.data.add_price * clicker.data.price_mult)
				clicker.data.amount += 1
				inventory.n_clicker = clicker.data.amount
				emit_signal("spawn_clicker")
		"ClickerLVL":
			if (inventory.essence >= clicker.data.upgrade_price):
				clicker.data.click_interval *= clicker.data.click_mult
				inventory.essence -= clicker.data.upgrade_price
				clicker.data.upgrade_price = int(clicker.data.upgrade_price * clicker.data.price_mult)
				clicker.data.lvl += 1
				emit_signal("upgrade_clicker")
				#print("[CLICKERS LVL] ", clicker.data.click_interval, " s")
		"CursorLVL":
			if (inventory.essence >= cursor.data.upgrade_price):
				cursor.data.click_amount += 1
				inventory.essence -= cursor.data.upgrade_price
				cursor.data.upgrade_price = int(cursor.data.upgrade_price * cursor.data.price_mult)
				cursor.data.lvl += 1
				#print("[CURSOR LEVEL] ", cursor_data.click_amount)
		"Tent":
			if (inventory.essence >= tent.data.add_price):
				inventory.essence -= tent.data.add_price
				inventory.multiplier += tent.data.multiplier
				tent.data.add_price = int(tent.data.add_price * tent.data.price_mult)
				tent.data.amount += 1
				inventory.n_tentacule = tent.data.amount
				emit_signal("spawn_tentacle")
				#print("[TENT] Game Mult: ", inventory.multiplier, " for ", tent.data.amount, " tentacles")
		"TentLVL":
			if (inventory.essence >= tent.data.upgrade_price):
				inventory.essence -= tent.data.upgrade_price
				inventory.multiplier -= tent.data.multiplier * tent.data.amount
				tent.data.multiplier *= 1.5
				inventory.multiplier += tent.data.multiplier * tent.data.amount
				tent.data.upgrade_price = int(tent.data.upgrade_price * tent.data.price_mult)
				tent.data.lvl += 1
				#print("[TENT] Tents mult: ", tent.data.multiplier)
		"Candle":
			if (inventory.essence >= candle.data.add_price):
				clicker.data.click_amount += 1
				tent.data.click_amount += 1
				inventory.essence -= candle.data.add_price
				candle.data.add_price = int(candle.data.add_price * candle.data.price_mult)
				candle.data.amount += 1
				emit_signal("spawn_candle")
	update_labels()
	emit_signal("update_essence")

func _on_phase_switch() -> void:
	set_phase_unlock()
