extends Action
class_name ShowMusicSelectionAction
func _init():		
	init_gramophonemod_properties()
	
func _run():
	var scene = load("res://mods/gramophone_music_mod/MusicSelectScene.tscn")
	var menu = scene.instance()
	menu.title = "Gramophone Cafe Music"
	menu.is_mobile = false
	MenuHelper.add_child(menu)
	yield (menu.run_menu(), "completed")
	menu.queue_free()
	if not SaveState.inventory.has_item(load("res://mods/gramophone_music_mod/MusicPlayerItem.tres")):
		yield(MenuHelper.give_item(load("res://mods/gramophone_music_mod/MusicPlayerItem.tres"),1,false), "completed")

	return true
	

func init_gramophonemod_properties():
	if not SaveState.other_data.has("GramophoneModProperties"):
		SaveState.other_data.GramophoneModProperties = {"altload":false,
														"current_track":"",
														"previous_track":"",
														"CafeTrack":"",
														"CafeAltLoad":false}	
	if SaveState.other_data.has("gramophone_mod_music"):
		if SaveState.other_data.gramophone_mod_music != "":
			SaveState.other_data.GramophoneModProperties["CafeTrack"] = SaveState.other_data.gramophone_mod_music
			SaveState.other_data.gramophone_mod_music = ""
	if SaveState.other_data.has("GramophoneMod_Mobile"):
		if SaveState.other_data.GramophoneMod_Mobile != "":
			SaveState.other_data.GramophoneModProperties["current_track"] = SaveState.other_data.GramophoneMod_Mobile
			SaveState.other_data.GramophoneMod_Mobile = ""	
