extends Node2D

var player 

signal forward

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("forward")

func display_text(text):
	var mylog = get_parent().get_node("ColorRect/Logs/Text")
	mylog.append_text(text+"\n")
	#log.scroll_to_line(log.get_line_count()-1)

func load_menu():
	$ColorRect/PlayerTurn/Load.disabled = true
	$ColorRect/PlayerTurn/New.disabled = true
	$ColorRect/StatsScreen.visible = false
	display_text("== Welcome to Basic Dungeon Crawler! ==")
	await forward
	if player.load_player():
		display_text("A save file has been found")
		$ColorRect/PlayerTurn/Load.disabled = false
		$ColorRect/StatsScreen.visible = true
		$ColorRect/StatsScreen.show_stats(player)
	else:
		display_text("No save has been found")
	$ColorRect/PlayerTurn/New.disabled = false

func _on_load_pressed() -> void:
	display_text("Glad to see you again, "+player.player_name)
	await forward
	get_parent().emit_signal("next")
	visible = false


func _on_new_pressed() -> void:
	display_text("Good luck out there")
	await forward
	player.init_player()
	get_parent().emit_signal("start")
	visible = false
