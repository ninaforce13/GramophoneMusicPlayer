extends Action
class_name ShowMusicSelectionAction

func _run():
	var scene = load("res://mods/gramophone_music_mod/Menus/MusicSelectScene.tscn")
	var menu = scene.instance()
	menu.title = "Gramophone Cafe Music"
	menu.is_mobile = false
	MenuHelper.add_child(menu)
	yield (menu.run_menu(), "completed")
	menu.queue_free()
	if not SaveState.inventory.has_item(load("res://mods/gramophone_music_mod/MusicPlayerItem.tres")):
		yield(MenuHelper.give_item(load("res://mods/gramophone_music_mod/MusicPlayerItem.tres"),1,false), "completed")

	return true
