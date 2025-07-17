extends Node2D

var player
var mob:Dictionary
var fight_stats:Dictionary

var weapon:Dictionary
var amulet:Dictionary
var gloves:Dictionary
var helmet:Dictionary

var turn

var player_hp
var mob_hp

signal forward

func create_mob(lvl):
	var temp_mob = {
		"hp":0, #2
		"attack":(randi_range(3,15)+lvl*randi_range(1,4))*randi_range(1,lvl), #3
		"magic":(randi_range(3,15)+lvl*randi_range(1,4))*randi_range(1,lvl), #4
		"defense":(randi_range(4,8)+lvl*randi_range(0,3))*randi_range(1,lvl), #5
		"resist":(randi_range(4,8)+lvl*randi_range(0,3))*randi_range(1,lvl), #6
		"initiative":(randi_range(1,3)+lvl*randi_range(0,1))*randi_range(1,lvl), #7
		"dmg_crit":(randi_range(5,20)+lvl*randi_range(0,1)*5)*randi_range(1,lvl), #8
		"cha_crit":(randi_range(1,20)+lvl*randi_range(0,2))*randi_range(1,lvl), #9
		"accuracy":(randi_range(1,10)+lvl*randi_range(0,2))*randi_range(1,lvl), #10
		"dodge":0, #11
		
		"wpn_dmg":(randi_range(30,100)+randi_range(10,randi_range(0,lvl))), #13
		"wpn_type":"magical" if +randi_range(0,1) == 1 else "physical", #14
		"wpn_acc":randi_range(30,100), #15
		"wpn_chcrit":randi_range(0,10)+int(randi_range(0,lvl)/2) #16
	}
	for i in range(lvl):
		temp_mob["hp"] += randi_range(4,15)
		temp_mob["dodge"] += randi_range(1,5)
	return temp_mob

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("forward")

func display_text(text):
	var mylog = get_parent().get_node("ColorRect/Logs/Text")
	mylog.append_text(text+"\n")
	#log.scroll_to_line(log.get_line_count()-1)

func update_stats():
	var stats = get_parent().get_node("ColorRect/StatsScreen")
	

func launch_fight():
	$ColorRect/PlayerTurn/Helmet.disabled = true
	$ColorRect/PlayerTurn/Amulet.disabled = true
	$ColorRect/PlayerTurn/Gloves.disabled = true
	$ColorRect/PlayerTurn/Weapon.disabled = true
	#get_parent().get_node("ColorRect/Logs/Text").clear()
	fight_stats = player.compute_stats()
	helmet = player.items["helmet"]
	amulet = player.items["amulet"]
	gloves = player.items["gloves"]
	weapon = player.items["weapon"]
	
	mob = create_mob(fight_stats["level"])
	player_hp = fight_stats["hp"]
	mob_hp = mob["hp"]
	get_node("ColorRect/StatsScreen").show_combat_stats(player, player_hp)
	$ColorRect/Combat/PlayerHp/CurrentHp.size.x = (float(player_hp)/fight_stats["hp"])*$ColorRect/Combat/PlayerHp.size.x
	$ColorRect/Combat/MobHp/CurrentHp.size.x = (float(mob_hp)/mob["hp"])*$ColorRect/Combat/MobHp.size.x
	
	display_text("[color=red]==== Fight ====[/color]")
	await forward
	
	if mob["initiative"] > fight_stats["initiative"]:
		display_text("L'ennemi vous surprend")
		await forward
		mob_turn()
	else:
		display_text("Vous prenez l'initiative")
		await forward
		player_turn()

func mob_turn():
	$ColorRect/PlayerTurn/Helmet.disabled = true
	$ColorRect/PlayerTurn/Amulet.disabled = true
	$ColorRect/PlayerTurn/Gloves.disabled = true
	$ColorRect/PlayerTurn/Weapon.disabled = true
	display_text("=== Mob Turn ===")
	await forward
	display_text("Le mob vous tape")
	await forward
	if randi_range(1,100)+fight_stats["dodge"] > mob["accuracy"] + mob["wpn_acc"]:
		display_text("Il vous rate")
		await forward
		player_turn()
		return
	
	var dmg = 0.
	if mob["wpn_type"] == "physical":
		display_text("Il saute à votre corps à corps")
		dmg = randi_range(int(0.6*mob["wpn_dmg"]), int(1.4*mob["wpn_dmg"]))*mob["attack"]
	else:
		display_text("Il récite une sombre incantation")
		dmg = randi_range(int(0.8*mob["wpn_dmg"]), int(1.2*mob["wpn_dmg"]))*mob["magic"]
	await forward
	dmg /= 100
	if randi_range(1,100) <= mob["cha_crit"] + mob["wpn_chcrit"]:
		display_text("Coup critique !")
		await forward
		dmg *= 1.5+mob["dmg_crit"]/100
	if mob["wpn_type"] == "physical":
		dmg *= 100./(100+fight_stats["defense"])
	else:
		dmg *= 100./(100+fight_stats["resist"])
	dmg = int(dmg)
	display_text("Il inflige " + str(dmg) + " dégats")
	await forward
	player_hp -= dmg
	$ColorRect/Combat/PlayerHp/CurrentHp.size.x = (float(player_hp)/fight_stats["hp"])*$ColorRect/Combat/PlayerHp.size.x
	get_node("ColorRect/StatsScreen").show_combat_stats(player, player_hp)
	
	if player_hp <= 0:
		display_text("Vous vous effondrez sous les coups")
		await forward
		display_text("[color=red]==== Game over ====[/color]")
		await forward
		get_parent().emit_signal("death")
	else:
		player_turn()

func player_turn():
	display_text("=== Player Turn ===")
	$ColorRect/PlayerTurn/Helmet.disabled = helmet.is_empty()
	$ColorRect/PlayerTurn/Amulet.disabled = amulet.is_empty()
	$ColorRect/PlayerTurn/Gloves.disabled = gloves.is_empty()
	$ColorRect/PlayerTurn/Weapon.disabled = weapon.is_empty()

func player_attack(tool):
	$ColorRect/PlayerTurn/Helmet.disabled = true
	$ColorRect/PlayerTurn/Amulet.disabled = true
	$ColorRect/PlayerTurn/Gloves.disabled = true
	$ColorRect/PlayerTurn/Weapon.disabled = true
	await forward
	if randi_range(1,100)+mob["dodge"] > fight_stats["accuracy"] + tool["wpn_acc"]:
		display_text("Votre ennemi esquive")
		await forward
		mob_turn()
		return
	var dmg = 0.
	if tool["wpn_type"] == "physical":
		dmg = randf_range(int(0.6*tool["wpn_dmg"]), int(1.4*tool["wpn_dmg"]))*fight_stats["attack"]
	else:
		dmg = randf_range(int(0.8*tool["wpn_dmg"]), int(1.2*tool["wpn_dmg"]))*fight_stats["magic"]
	await forward
	dmg /= 100
	if randf_range(1,100) <= fight_stats["cha_crit"] + tool["wpn_chcrit"]:
		display_text("Coup critique !")
		await forward
		dmg *= 1.5+fight_stats["dmg_crit"]/100
	if tool["wpn_type"] == "physical":
		dmg *= 100./(100+mob["defense"])
	else:
		dmg *= 100./(100+mob["resist"])
	dmg = int(dmg)
	display_text("Vous infligez " + str(dmg) + " dégats")
	await forward
	mob_hp -= dmg
	$ColorRect/Combat/MobHp/CurrentHp.size.x = (float(mob_hp)/mob["hp"])*$ColorRect/Combat/MobHp.size.x
	
	
	if mob_hp <= 0:
		display_text("=== Vous abattez le monstre ===")
		await forward
		var exp = randi_range(player.stats["level"]*5, player.stats["level"]*10)
		display_text("Vous gagnez " + str(exp) + " points d'expérience")
		await forward
		player.exp += exp
		if player.exp > player.stats["experience"]:
			display_text("== Vous gagnez un niveau ==")
			await forward
			player.stats["level"] += 1
			for s in player.base_stats:
				player.stats[s] += randi_range(player.stats[s]*0.01, player.stats[s]*0.1)
			player.exp -= player.stats["experience"]
			player.stats["experience"] = int(10*pow(player.stats["level"],2))
			get_node("ColorRect/StatsScreen").show_combat_stats(player, player_hp)
			display_text("Vous êtes maintenant niveau "+str(player.stats["level"]))
			await forward
		display_text("Encore "+str(player.stats["experience"]-player.exp) + " exp avant prochain niveau")
		await forward
		get_parent().emit_signal("next")
	else:
		mob_turn()

func _on_weapon_pressed() -> void:
	if weapon["wpn_type"] == "physical":
		display_text("Vous abattez sauvagement votre lame")
	else:
		display_text("Vous invoquez des lames d'air aiguisées")
	player_attack(weapon)

func _on_weapon_button_down() -> void:
	get_node("ColorRect/StatsScreen").show_wpn_stats(weapon)

func _on_gloves_pressed() -> void:
	if gloves["wpn_type"] == "physical":
		display_text("Vous assénez un coup brutal")
	else:
		display_text("Vous génerez une violente onde de choc")
	player_attack(gloves)

func _on_gloves_button_down() -> void:
	get_node("ColorRect/StatsScreen").show_wpn_stats(gloves)

func _on_amulet_pressed() -> void:
	if amulet["wpn_type"] == "physical":
		display_text("Vous invoquez des lames volantes")
	else:
		display_text("Vous déchainez un puissant brasier")
	player_attack(amulet)

func _on_amulet_button_down() -> void:
	get_node("ColorRect/StatsScreen").show_wpn_stats(amulet)

func _on_helmet_pressed() -> void:
	if helmet["wpn_type"] == "physical":
		display_text("Vous chargez soudainement tête la première")
	else:
		display_text("Vous projetez un rayon destructeur")
	player_attack(helmet)

func _on_helmet_button_down() -> void:
	get_node("ColorRect/StatsScreen").show_wpn_stats(helmet)
