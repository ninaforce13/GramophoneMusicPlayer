extends ContentInfo

func _init() -> void:
	var res: Resource = preload("LevelMap_Ext.gd")	
	res.take_over_path("res://world/core/LevelMap.gd")
	var res2: Resource = preload("BattleAction_Ext.gd")
	res2.take_over_path("res://nodes/actions/BattleAction.gd")
	var gramophone:Resource = preload("res://mods/gramophone_music_mod/Objects/Gramophone_player.tscn")
	gramophone.take_over_path("res://world/objects/static_physics/gramophone_props/gramophone/gramophone_player.tscn")
