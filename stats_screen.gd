extends Node2D

func ser(f):
	return str(int(f))

func show_combat_stats(player, cur_hp):
	var stats = player.compute_stats()
	$ColorRect/PlayerStats.clear()
	$ColorRect/PlayerStats.append_text("\t"+player.player_name+"\n")
	$ColorRect/PlayerStats.append_text("hp"+": "+ser(cur_hp)+"/"+ser(stats["hp"])+"\n")
	$ColorRect/PlayerStats.append_text("attack"+": "+ser(stats["attack"])+"\n")
	$ColorRect/PlayerStats.append_text("magic"+": "+ser(stats["magic"])+"\n")
	$ColorRect/PlayerStats.append_text("defense"+": "+ser(stats["defense"])+"\n")
	$ColorRect/PlayerStats.append_text("resist"+": "+ser(stats["resist"])+"\n")
	$ColorRect/PlayerStats.append_text("initiative"+": "+ser(stats["initiative"])+"\n")
	$ColorRect/PlayerStats.append_text("crit dmg"+": "+ser(stats["dmg_crit"])+"\n")
	$ColorRect/PlayerStats.append_text("crit chance"+": "+ser(stats["cha_crit"])+"\n")
	$ColorRect/PlayerStats.append_text("accuracy"+": "+ser(stats["accuracy"])+"\n")
	$ColorRect/PlayerStats.append_text("dodge"+": "+ser(stats["dodge"])+"\n")
	$ColorRect/PlayerStats.append_text("experience"+": "+ser(player.exp)+"/"+ser(stats["experience"])+" (level " + ser(player.stats["level"]) + ")\n")

func show_stats(player):
	var stats = player.compute_stats()
	$ColorRect/PlayerStats.clear()
	$ColorRect/PlayerStats.append_text("\t"+player.player_name+"\n")
	$ColorRect/PlayerStats.append_text("hp"+": "+ser(stats["hp"])+"\n")
	$ColorRect/PlayerStats.append_text("attack"+": "+ser(stats["attack"])+"\n")
	$ColorRect/PlayerStats.append_text("magic"+": "+ser(stats["magic"])+"\n")
	$ColorRect/PlayerStats.append_text("defense"+": "+ser(stats["defense"])+"\n")
	$ColorRect/PlayerStats.append_text("resist"+": "+ser(stats["resist"])+"\n")
	$ColorRect/PlayerStats.append_text("initiative"+": "+ser(stats["initiative"])+"\n")
	$ColorRect/PlayerStats.append_text("crit dmg"+": "+ser(stats["dmg_crit"])+"\n")
	$ColorRect/PlayerStats.append_text("crit chance"+": "+ser(stats["cha_crit"])+"\n")
	$ColorRect/PlayerStats.append_text("accuracy"+": "+ser(stats["accuracy"])+"\n")
	$ColorRect/PlayerStats.append_text("dodge"+": "+ser(stats["dodge"])+"\n")
	$ColorRect/PlayerStats.append_text("experience"+": "+ser(player.exp)+"/"+ser(stats["experience"])+" (level " + ser(player.stats["level"]) + ")\n")

func show_wpn_stats(wpn:Dictionary):
	$ColorRect/WpnStats.clear()
	$ColorRect/WpnStats.append_text("ratio"+": "+ser(wpn["wpn_dmg"])+"%\n")
	$ColorRect/WpnStats.append_text("type"+": "+wpn["wpn_type"]+"\n")
	$ColorRect/WpnStats.append_text("accuracy"+": "+ser(wpn["wpn_acc"])+"\n")
	$ColorRect/WpnStats.append_text("crit chance"+": "+ser(wpn["wpn_chcrit"])+"\n")

func hide_stats():
	$ColorRect/PlayerStats.clear()

func hide_wpn_stats():
	$ColorRect/WpnStats.clear()
