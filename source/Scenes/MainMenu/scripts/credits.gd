extends TabContainer

@export var pre_scene: Node
@onready var animation_player: AnimationPlayer = $Credits/HBoxContainer/VBoxContainer/AnimationPlayer

func _ready():
	hide()

func reset_focus():
	$Credits.grab_focus()
	animation_player.seek(0)
	animation_player.play("show_text")

func _on_back_pressed():
	hide()
	pre_scene.reset_focus()
	AudioManager.play_button_sound()
