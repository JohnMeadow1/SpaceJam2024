extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sound_player: AudioStreamPlayer = $SoundPlayer

func _ready():
	pass # Replace with function body.

func play_button_sound():
	sound_player.play()
	pass

func play_music_sound():
	music_player.play()
	pass

func set_pitch(in_value):
	music_player.pitch_scale = in_value
	
