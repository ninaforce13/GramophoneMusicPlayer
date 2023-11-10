extends BattleAction

func _run():
	var e = get_encounter(self, encounter_name_override)
	if e == null:
		push_error("Couldn't find EncounterConfig for BattleAction")
		return false
	print("modded script ran")
	if music_mod_override():
		e.music_override = load_music()	
		e.music_vox_override = load_music()	
	var config = e.get_config()
	var result = yield (_run_encounter(e, config), "completed")
	
	return _handle_battle_result(result)
	
func music_mod_override()->bool:
	if not SaveState.other_data.has("GramophonePlayerData"):
		return false
	if not SaveState.other_data.GramophonePlayerData.has("BattleData"):
		return false
	return true

func load_music():	
	if SaveState.other_data.GramophonePlayerData.BattleData.altload or SaveState.other_data.GramophonePlayerData.BattleData.path == "mute":
		return load_external_ogg(SaveState.other_data.GramophonePlayerData.BattleData.path)
	else:
		return load(SaveState.other_data.GramophonePlayerData.BattleData.path)

func load_external_ogg(path):
	if path == "mute":
		return AudioStreamMP3.new()
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
