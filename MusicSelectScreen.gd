extends "res://menus/BaseMenu.gd"

export (Color) var invalid_label_color:Color
export (Array, Array, String) var music_list
export (String) var title:String
export (bool) var is_mobile:bool
onready var inputs = find_node("Inputs")
onready var main_select_btn = find_node("Set Overworld Music")
onready var battle_select_btn = find_node("Set Battle Music")
onready var headerlabel = find_node("HeaderLabel")
const overworld_text = "Set Overworld Track"
const cafe_text = "Set Cafe Track"
var songs:Array				
func _init():		
	init_gramophonemod_properties()

func init_gramophonemod_properties():
	if not SaveState.other_data.has("GramophoneModProperties"):
		SaveState.other_data.GramophoneModProperties = {"altload":false,
														"current_track":"",
														"previous_track":"",
														"CafeTrack":"",
														"CafeAltLoad":false,
														"battle_track":""}	
	if SaveState.other_data.has("gramophone_mod_music"):
		if SaveState.other_data.gramophone_mod_music != "":
			SaveState.other_data.GramophoneModProperties["CafeTrack"] = SaveState.other_data.gramophone_mod_music
			SaveState.other_data.gramophone_mod_music = ""
	if SaveState.other_data.has("GramophoneMod_Mobile"):
		if SaveState.other_data.GramophoneMod_Mobile != "":
			SaveState.other_data.GramophoneModProperties["current_track"] = SaveState.other_data.GramophoneMod_Mobile
			SaveState.other_data.GramophoneMod_Mobile = ""	
																	
func _ready():
	main_select_btn.text = overworld_text
	if not is_mobile:
		main_select_btn.text = cafe_text
		var container = battle_select_btn.get_parent()
		container.remove_child(battle_select_btn)
	var music_directory = "user://music/"
	songs = build_track_list(music_directory)		
	_add_heading(title)	
	if DLC.has_dlc("pier"):
		print("Pier DLC found.")
		var dlc_songs = add_pier_dlc_tracks()
		for track in dlc_songs:
			music_list.append(track)			
	for track in songs:
		music_list.append(track)	
	var index = 0		
	var alt_load_flag:bool = index >= 65 if not DLC.has_dlc("pier") else index >= 74
	for song in music_list:		
		_add_input(song, index+1)
		index += 1
			
		
	inputs.setup_focus()

func add_pier_dlc_tracks()->Array:
	var results:Array = []
	results.push_back(["Clown Battle 1 (DLC)","res://dlc/01_pier/music/clown_battle_1.ogg"])
	results.push_back(["Clown Battle 2 (DLC)","res://dlc/01_pier/music/clown_battle_2.ogg"])
	results.push_back(["Engine Battle (DLC)","res://dlc/01_pier/music/engine_battle.ogg"])
	results.push_back(["Fun House (DLC)","res://dlc/01_pier/music/funhouse.ogg"])
	results.push_back(["Gwen's Theme 1 (DLC)","res://dlc/01_pier/music/gwen_theme_1.ogg"])
	results.push_back(["Gwen's Theme 2 (DLC)","res://dlc/01_pier/music/gwen_theme_2.ogg"])
	results.push_back(["Haunted House (DLC)","res://dlc/01_pier/music/hauntedhouse.ogg"])
	results.push_back(["Pier of The Unknown (DLC)","res://dlc/01_pier/music/pier.ogg"])
	results.push_back(["Space World (DLC)","res://dlc/01_pier/music/spaceworld.ogg"])
	return results

func build_track_list(dirname:String, dlc_tag:bool = false):
	var dir:Directory = Directory.new()
	if not dir.dir_exists(dirname):
		push_error("Directory does not exist")
		return []
	var err = dir.open(dirname)
	if err != OK:
		push_error("Cannot open dir " + dirname)
		return []
	err = dir.list_dir_begin(true, true)
	if err != OK:
		push_error("Cannot list " + dirname)
		return []
	
	var results = []	
	var count:int = 0
	while true:
		var file = dir.get_next()
		if file == "":
			print("processed " + str(count) + " files.")
			break	
		if file.get_extension() == "import":
			continue		
		var track = dirname+file
		var file_name:String = file.get_basename()
		file_name = file_name.replacen("_"," ")
		file_name = file_name.capitalize()
		if dlc_tag:
			file_name = file_name + " (DLC)"
		results.push_back([file_name, track])
		count+=1
	dir.list_dir_end()
	return results
	

func load_external_ogg(path):
	var ogg_file = File.new()
	var err = ogg_file.open(path, File.READ)
	if err != OK:
		return null
	var bytes = ogg_file.get_buffer(ogg_file.get_len())	
	var stream = AudioStreamMP3.new()	
	stream.data = bytes
	stream.loop = true
	ogg_file.close()
	return stream


func _add_heading(text:String):
	headerlabel.text = title	

func _add_input(song, index):
	var button = preload("res://menus/inventory/InventoryItemButton.tscn").instance()	
	button.text = str(index) + ".  "+ song[0]
	button.clip_text = false
	inputs.add_child(button)
					
func grab_focus():
	inputs.grab_focus()
	
func _on_ExitButton_pressed():
	var focus_owner = get_focus_owner()
	if focus_owner:
		focus_owner.grab_focus()	
	cancel()


func _on_Preview_pressed():
	var focus_owner = get_focus_owner()
	var track
	var track_path
	if focus_owner:
		var index = 0
		for child in inputs.get_children():
			if child == focus_owner:
				break
			index += 1

		if index != 0:
			var alt_load_flag:bool = index >= 65 if not DLC.has_dlc("pier") else index >= 74
			if alt_load_flag:
				track = load_external_ogg(music_list[index][1])
				if track == null:
					print("Error reading file: " + music_list[index][1])
					return
				track_path = music_list[index][1]
			else:
				track = load(music_list[index][1])
				track_path = music_list[index][1]
		else:
			if WorldSystem.time.is_night():			
				track = SceneManager.current_scene.region_settings.music_night
				track_path = ""
				
			else:
				track = SceneManager.current_scene.region_settings.music_day
				track_path = ""
		MusicSystem.play_now(track)
		SaveState.other_data.GramophoneModProperties["previous_track"] = track_path		


func _on_Set_Battle_Music_pressed():
	var track_data = get_track_data()
	var confirm_msg = "Set [" + track_data["name"] + "] as Battle Music?"
	if not track_data:
		return	
	var focus_owner = get_focus_owner()
	if yield (MenuHelper.confirm(confirm_msg), "completed"):				
		SaveState.other_data.GramophoneModProperties["battle_track"] = track_data["path"] 
	focus_owner.grab_focus()

func _on_Set_Overworld_Music_pressed():	
	var track_data = get_track_data()
	if not track_data:
		return
	var confirm_msg = ""
	if not is_mobile:		
		confirm_msg = "Set [" + track_data["name"] + "] as Cafe Music?"
		SaveState.other_data.GramophoneModProperties["CafeTrack"] = track_data["path"]
		SaveState.other_data.GramophoneModProperties["CafeAltLoad"] = track_data["altload"]
	if is_mobile:
		#Set previous track
		if SaveState.other_data.GramophoneModProperties["current_track"] != "":
			SaveState.other_data.GramophoneModProperties["previous_track"] = SaveState.other_data.GramophoneModProperties["current_track"]
		#Set new current track
		SaveState.other_data.GramophoneModProperties["current_track"] = track_data["path"]
		SaveState.other_data.GramophoneModProperties["altload"] = track_data["altload"]		
		#Initialize previous track if it's empty
		if SaveState.other_data.GramophoneModProperties["previous_track"] == "":
			SaveState.other_data.GramophoneModProperties["previous_track"] = track_data["path"]
		confirm_msg = "Set [" + track_data["name"] +"] as Overworld Music?"
	var focus_owner = get_focus_owner()
	if yield (MenuHelper.confirm(confirm_msg), "completed"):
		var track
		if typeof(track_data["path"]) == TYPE_STRING:
			if track_data["path"] == "":
				if WorldSystem.time.is_night():			
					track = SceneManager.current_scene.region_settings.music_night
				else:
					track = SceneManager.current_scene.region_settings.music_day
			elif track_data["altload"]:				
				track = load_external_ogg(track_data["path"])
				if track == null:
					print("Error reading file: " + track_data["path"])
					return
			else:				
				track = load(track_data["path"])		
					
			MusicSystem.play_now(track)
		cancel()
	else:
		focus_owner.grab_focus()

func get_track_data()->Dictionary:
	var focus_owner = get_focus_owner()
	var track_data = {"file":"", "path":"","name":"", "altload":false}
	if focus_owner:
		var index = 0
		for child in inputs.get_children():
			if child == focus_owner:
				break
			index += 1
		var alt_load_flag:bool = index >= 65 if not DLC.has_dlc("pier") else index >= 74
		track_data["name"] = music_list[index][0]
		track_data["altload"] = alt_load_flag
		if index != 0:
			if alt_load_flag:
				track_data["file"] = load_external_ogg(music_list[index][1])
				
				if track_data["file"] == null:
					print("Error reading file: " + music_list[index][1])
					return {}
				track_data["path"] = music_list[index][1]
			else:
				track_data["file"] = load(music_list[index][1])
				track_data["path"] = music_list[index][1]
		else:
			if WorldSystem.time.is_night():			
				track_data["file"] = SceneManager.current_scene.region_settings.music_night
				track_data["path"] = ""
				
			else:
				track_data["file"] = SceneManager.current_scene.region_settings.music_day
				track_data["path"] = ""	
		
	return track_data
