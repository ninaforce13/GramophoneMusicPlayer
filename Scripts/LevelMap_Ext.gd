static func patch():
	var script_path = "res://world/core/LevelMap.gd"
	var patched_script : GDScript = preload("res://world/core/LevelMap.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var class_name_index = code_lines.find("class_name LevelMap")
	if class_name_index >= 0:
		code_lines.remove(class_name_index)

	var code_index = code_lines.find("func _update_music():")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("change_music"))

	code_index = code_lines.find("func _ready():")
	if code_index > 0:
		code_lines.insert(code_index-1,get_code("new_vars"))

	code_lines.insert(code_lines.size()-1,get_code("new_functions"))


	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"
	LevelMap.source_code = patched_script.source_code
	var err = LevelMap.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return


static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["change_music"] = """
	if music_mod_override():
		custom_music_set()
		return
	"""

	code_blocks["new_functions"] = """
func custom_music_set():
	alt_track = SaveState.other_data.GramophonePlayerData.OverworldData.path
	alt_load = 	SaveState.other_data.GramophonePlayerData.OverworldData.altload
	if region_settings:
		if region_settings.region_name == "REGION_NAME_CAFE":
			alt_track = SaveState.other_data.GramophonePlayerData.CafeData.path
			alt_load = 	SaveState.other_data.GramophonePlayerData.CafeData.altload

	previous_track = SaveState.other_data.GramophonePlayerData.OverworldData.previous_path

	var music:AudioStream = music_override
	if not music and region_settings:
		if not UserSettings.audio_vocals and region_settings.music_no_vox:
			music = region_settings.music_no_vox
		elif WorldSystem.time.is_night():
			music = region_settings.music_night
		else :
			music = region_settings.music_day
	if is_inside_tree():
		if alt_track != "" and ( alt_track == previous_track ) and MusicSystem.current_track != null:
			return
		if alt_track != "" and alt_load and alt_track != "mute":
			music = load_external_ogg(alt_track)
			SaveState.other_data.GramophonePlayerData.OverworldData.previous_path = alt_track
		if alt_track != "" and not alt_load and alt_track != "mute":
			music = load(alt_track)
			SaveState.other_data.GramophonePlayerData.OverworldData.previous_path = alt_track
		if alt_track == "":
			SaveState.other_data.GramophonePlayerData.OverworldData.previous_path = ""
		if alt_track == "mute":
			music = null
		if MusicSystem.current_track == music:
			return
		if music == null:
			MusicSystem.fade_out()
		else :
			MusicSystem.play(music)

func load_external_ogg(path):
	var ogg_file = File.new()
	var err = ogg_file.open(path, File.READ)
	if err != OK:
		return get_default_track()
	var bytes = ogg_file.get_buffer(ogg_file.get_len())
	if bytes == null:
		return get_default_track()
	var stream = AudioStreamMP3.new()
	stream.data = bytes
	stream.loop = true
	ogg_file.close()
	return stream


func get_default_track():
	var music
	if WorldSystem.time.is_night():
		music = region_settings.music_night
	else :
		music = region_settings.music_day
	SaveState.other_data.GramophonePlayerData.OverworldData.path = ""
	return music

func music_mod_override()->bool:
	if not SaveState.other_data.has("GramophonePlayerData"):
		return false
	if not SaveState.other_data.GramophonePlayerData.has("OverworldData"):
		return false
	return true
	"""

	code_blocks["new_vars"] = """
var alt_track = ""
var alt_load = false
var previous_track = ""
	"""

	return code_blocks[block]

