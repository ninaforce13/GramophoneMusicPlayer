static func patch():
	var script_path = "res://nodes/actions/BattleAction.gd"
	var patched_script : GDScript = preload("res://nodes/actions/BattleAction.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var class_name_index = code_lines.find("class_name BattleAction")
	if class_name_index >= 0:
		code_lines.remove(class_name_index)

	var code_index = code_lines.find("	var config = e.get_config()")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("replace_old"))
		code_lines.insert(code_index-1,get_code("change_music"))

	code_lines.insert(code_lines.size()-1,get_code("new_functions"))

	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"
	BattleAction.source_code = patched_script.source_code
	var err = BattleAction.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return


static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["change_music"] = """
	var old_override
	var old_override_vox
	if music_mod_override():
		if e.music_override:
			old_override = e.music_override.duplicate()
		if e.music_vox_override:
			old_override_vox = e.music_vox_override.duplicate()
		e.music_override = load_music()
		e.music_vox_override = load_music()
	"""

	code_blocks["replace_old"] = """
	e.music_override = old_override
	e.music_vox_override = old_override_vox
"""

	code_blocks["new_functions"] = """
func music_mod_override()->bool:
	if not SaveState.other_data.has("GramophonePlayerData"):
		return false
	if not SaveState.other_data.GramophonePlayerData.has("BattleData"):
		return false
	if SaveState.other_data.GramophonePlayerData.BattleData.path == "":
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
	"""

	return code_blocks[block]
