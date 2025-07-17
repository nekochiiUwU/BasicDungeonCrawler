extends Node2D

var save_file = "user://jdr.save"


var base_stats = ["hp", "attack", "magic", "defense", "resist", "initiative", "dmg_crit", "cha_crit", "accuracy", "dodge"]
var stats: Dictionary = {
	"level": 0,
	"hp":0,
	"attack":0,
	"magic":0,
	"defense":0,
	"resist":0,
	"initiative":0,
	"dmg_crit":0,
	"cha_crit":0,
	"accuracy":0,
	"dodge":0,
	"experience":0,
}

var items: Dictionary = {
	"helmet":{},
	"amulet":{},
	"gloves":{},
	"weapon":{},
	"shoulder":{},
	"torso":{},
	"belt":{},
	"pants":{},
	"boots":{},
	"wrists":{},
	"rune":{},
	"ring":{},
}

var exp = 0
var next = 0
var player_name = "sample"

func init_player():
	stats = {}
	items = {
	"helmet":{},
	"amulet":{},
	"gloves":{},
	"weapon":{},
	"shoulder":{},
	"torso":{},
	"belt":{},
	"pants":{},
	"boots":{},
	"wrists":{},
	"rune":{},
	"ring":{},
	}
	
	stats["level"] = 1
	stats["hp"] = 20
	stats["attack"] = 10
	stats["magic"] = randi_range(5,15)
	stats["defense"] = 10
	stats["resist"] = 10
	stats["initiative"] = 3
	stats["dmg_crit"] = 1
	stats["cha_crit"] = 2
	stats["accuracy"] = 2
	stats["dodge"] = 5
	stats["experience"] = 20
	
	items["weapon"]["wpn_dmg"] = 50
	items["weapon"]["wpn_type"] = "physical"
	items["weapon"]["wpn_acc"] = 60
	items["weapon"]["wpn_chcrit"] = 3
	
	exp = 0
	next = 5

func destroy_savefile():
	DirAccess.remove_absolute(save_file)

func load_player():
	if !FileAccess.file_exists(save_file):
		init_player()
		return false
	var save = FileAccess.open(save_file, FileAccess.READ)
	var data = save.get_line()
	var saved_data = JSON.parse_string(data)
	player_name = saved_data["player_name"]
	exp = int(saved_data["exp"])
	next = int(saved_data["next"])
	stats = saved_data["stats"]
	items = saved_data["items"]
	return true

func save_player():
	var save_dict = {
		"player_name":player_name,
		"exp":exp,
		"next":next,
		"stats":stats,
		"items":items
	}
	var save = FileAccess.open(save_file, FileAccess.WRITE)
	save.store_line(JSON.stringify(save_dict))

func compute_stats():
	var new_stats = stats.duplicate(true)
	for item in items.values():
		for key in item.keys():
			if !key.begins_with("wpn"):
				new_stats[key] += item[key]
	return new_stats
