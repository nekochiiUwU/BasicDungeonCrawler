extends Node2D

var player

var tool_list = ["helmet","gloves","amulet","weapon"]
var artifact_list = ["ring","rune"]
var color_rarity = ["dark_gray", "dark_green", "blue", "purple", "yellow"]
var type
var rolled_stats

signal forward

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("forward")

func display_text(text):
	var mylog = get_parent().get_node("ColorRect/Logs/Text")
	mylog.append_text(text+"\n")
	#dlog.scroll_to_line(log.get_line_count()-1)

func get_diff(a,b):
	if a is String or b is String:
		return " ("+("null" if b is int else b)+")"
	if a > b:
		return " [color=dark_green](+"+str(a-b)+")[/color]"
	elif a == b:
		return " [color=dark_gray](+"+str(a-b)+")[/color]"
	else:
		return " [color=red]("+str(a-b)+")[/color]"

func show_stats(stats:Dictionary, equipped:Dictionary):
	$ColorRect/Loot/ItemStats.clear()
	var temp_keys = stats.keys()
	for k in equipped.keys():
		if !(k in stats.keys()):
			temp_keys.append(k)
	for key in temp_keys:
		if !key.begins_with("wpn"):
			$ColorRect/Loot/ItemStats.append_text(key+": "+str(stats.get(key,0)) + get_diff(stats.get(key,0),equipped.get(key,0)) + "\n")


func show_wpn_stats(wpn:Dictionary, equipped:Dictionary):
	$ColorRect/Loot/WpnStats.clear()
	for key in wpn.keys():
		if key.begins_with("wpn"):
			$ColorRect/Loot/WpnStats.append_text(key.trim_prefix("wpn_") + ": " + str(wpn[key]) + get_diff(wpn.get(key,0),equipped.get(key,0)) + "\n")

func hide_stats():
	$ColorRect/Loot/ItemStats.clear()

func hide_wpn_stats():
	$ColorRect/Loot/WpnStats.clear()

func loot_item():
	hide_stats()
	hide_wpn_stats()
	$ColorRect/PlayerTurn/Take.disabled = true
	$ColorRect/PlayerTurn/Skip.disabled = true
	get_node("ColorRect/StatsScreen").show_stats(player)
	display_text("[color=dark_green]==== Loot ====[/color]")
	await forward
	
	type = player.items.keys().pick_random()
	var lvl = player.stats["level"]
	var rar_roll = randi_range(0,100)
	var rarity = 1
	if rar_roll > 97:
		rarity = 5
	elif rar_roll > 90:
		rarity = 4
	elif rar_roll > 75:
		rarity = 3
	elif rar_roll > 45:
		rarity = 2
	if type in artifact_list:
		rarity *= 2
	rolled_stats = {}
	
	if type in tool_list:
		rolled_stats["wpn_dmg"] = randi_range(30,100)+randi_range(10,lvl*10)
		rolled_stats["wpn_type"] = ["magical","physical"].pick_random()
		rolled_stats["wpn_acc"] = randi_range(30,100)
		rolled_stats["wpn_chcrit"] = randi_range(0,10 + int(lvl/2))
		show_wpn_stats(rolled_stats, player.items[type])
	for i in rarity:
		var stat = ["hp","attack","magic","defense","resist","initiative","dmg_crit","cha_crit","accuracy","dodge"].pick_random()
		if !(stat in rolled_stats):
			rolled_stats[stat] = 0
		for j in range(lvl):
			if stat == "hp":
				rolled_stats[stat] += randi_range(1,8)
			elif stat == "attack" or stat == "magic":
				rolled_stats[stat] += randi_range(1,6)
			elif stat == "defense" or stat == "resist":
				rolled_stats[stat] += randi_range(1,4)
			if stat == "initiative":
				rolled_stats[stat] += randi_range(3,8)
			if stat == "dmg_crit":
				rolled_stats[stat] += randi_range(2,5)
			if stat == "accuracy" or stat == "dodge":
				rolled_stats[stat] += randi_range(1,5)
			if stat == "dodge":
				rolled_stats[stat] += randi_range(0,3)
	show_stats(rolled_stats, player.items[type])
	if type in artifact_list:
		rarity /= 2
	display_text("Vous trouvez un nouvel objet [color="+color_rarity[rarity-1]+"]("+ type+")[/color]")
	await forward
	display_text("Le prendre ?")
	$ColorRect/PlayerTurn/Take.disabled = false
	$ColorRect/PlayerTurn/Skip.disabled = false

func _on_take_pressed() -> void:
	player.items[type] = rolled_stats
	get_parent().emit_signal("next")

func _on_skip_pressed() -> void:
	get_parent().emit_signal("next")
