extends LevelMap

var alt_track = ""
var alt_load = false
var previous_track = ""
	
func _update_music():	
	if not music_mod_override():
		._update_music()
		return
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
		if alt_track != "" and alt_load:				
			music = load_external_ogg(alt_track)
			SaveState.other_data.GramophonePlayerData.OverworldData.previous_path = alt_track
		if alt_track != "" and not alt_load:	
			music = load(alt_track)
			SaveState.other_data.GramophonePlayerData.OverworldData.previous_path = alt_track
		if alt_track == "":
			SaveState.other_data.GramophonePlayerData.OverworldData.previous_path = "" 
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

