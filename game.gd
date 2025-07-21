extends Node2D

@onready var player_scene = load("res://Player.tscn")
@onready var fight_scene = load("res://Fight.tscn")
@onready var loot_scene = load("res://Loot.tscn")
@onready var menu_scene = load("res://Menu.tscn")
@onready var popup_scene = load("res://NamePopup.tscn")

var player
var fight
var menu
var loot

signal next
signal death
signal start
signal go_menu

func _ready() -> void:
	$ColorRect/Logs/Text.clear()
	player = player_scene.instantiate()
	
	menu = menu_scene.instantiate()
	menu.player = player
	
	fight = fight_scene.instantiate()
	fight.player = player
	
	loot = loot_scene.instantiate()
	loot.player = player
	
	add_child(menu)
	add_child(fight)
	add_child(loot)
	fight.visible = false
	loot.visible = false
	menu.visible = false

	connect("death", handle_death)
	connect("next", next_event)
	connect("start", handle_start)
	connect("go_menu", handle_menu)
	emit_signal("go_menu")

func handle_start():
	var popup = popup_scene.instantiate()
	add_child(popup)
	await popup.get_node("Button").pressed
	player.player_name = popup.get_node("TextEdit").text
	popup.queue_free()
	emit_signal("next")

func handle_menu():
	menu.load_menu()
	menu.visible = true

func handle_death():
	fight.visible = false
	loot.visible = false
	player.destroy_savefile()
	emit_signal("go_menu")

func next_event():
	player.save_player()
	fight.visible = false
	loot.visible = false
	if randi_range(1,10) + player.next <= 5:
		fight.visible = true
		fight.launch_fight()
		player.next += 1.5
	else:
		loot.visible = true
		loot.loot_item()
		player.next -= 1
