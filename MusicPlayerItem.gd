extends BaseItem

func get_use_options(_node, _context_kind:int, _context)->Array:
	return [{"label":"Change Track", "arg":null}]

func _use_in_world(_node, _context, _arg):
	
	GlobalMessageDialog.clear_state()
	open_track_list()		
	return true

func open_track_list():
	var scene = load("res://mods/gramophone_music_mod/MusicSelectScene.tscn")	
	var menu = scene.instance()
	menu.title = "Overworld Music"
	menu.is_mobile = true
	MenuHelper.add_child(menu)
	yield (menu.run_menu(), "completed")
	menu.queue_free()
	return true	

