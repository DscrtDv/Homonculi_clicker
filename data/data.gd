class_name Data
extends Resource

@export var phase		: int = 1
@export var phase_index : int = 0
@export var max_phase	: int = 4
@export var cursor 		: Entity
@export var clickers 	: Entity
@export var tentacles 	: Entity
@export var candles		: Entity
@export var inventory 	: Inventory
@export var floating_text : PackedScene

var phases_data = {
	"name": ["Essence", "Coal", "Iron", "Silver", "Gold", "Blood", "Soul", "God"],
	"max_score": [1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, INF],
	"hm_sprite": [
		"res://Animation/p1_homunculus.tres",
		"res://Animation/p2_homunculus.tres",
		"res://Animation/p3_homunculus.tres",
		"res://Animation/p4_homunculus.tres"
		],
	"hm_rad": [12, 28.5, 64, 128]
}

# Candle Line Tentacle and FX are relative to the Homunculus
var zindex = {
	"background"	: -100,
	"lines"			: -3,
	"candle"		: -2,
	"tentacle"		: -1,
	"fx"			: -1,
	"clicker"		: 0,
	"homunculus"	: 1,
	"UI"			: 100,
}