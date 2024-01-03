extends ContentInfo
var levelmap_patch = preload("res://mods/gramophone_music_mod/Scripts/LevelMap_Ext.gd")
var battleaction_patch = preload("res://mods/gramophone_music_mod/Scripts/BattleAction_Ext.gd")
func _init():
	levelmap_patch.patch()
	battleaction_patch.patch()
	var gramophone:Resource = preload("res://mods/gramophone_music_mod/Objects/Gramophone_player.tscn")
	gramophone.take_over_path("res://world/objects/static_physics/gramophone_props/gramophone/gramophone_player.tscn")
