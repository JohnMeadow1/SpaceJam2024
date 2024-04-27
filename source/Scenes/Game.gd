extends Node2D
class_name Game

@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var settings: TabContainer = $CanvasLayer/Panel/Settings
@onready var map: Map = $Map
@onready var restart: Button = $CanvasLayer/Panel/PauseMenu/Restart
@onready var resume: Button = $CanvasLayer/Panel/PauseMenu/Resume
@onready var gameover: Label = $CanvasLayer/Panel/GameOver
@onready var hight_score: Label = $CanvasLayer/Panel/Hight


var is_game_over = false
var max_score

'''
Flow chart
Game <==> Pause Menu ==> Settings
'''

func _ready():
	ui_layer.hide()
	map.game = self

func _input(event: InputEvent):
	if event.is_action_pressed("Escape"):
		if not ui_layer.visible:
			show_ui_layer()
		else:
			resume_game()

func show_ui_layer():
	pause_game()
	ui_layer.show()
	reset_focus()
	
func game_over():
	is_game_over = true
	resume.visible = false
	restart.visible = true
	gameover.visible = true
	hight_score.visible = true
	hight_score.text = str("Score: ", map.max_entropy)
	ui_layer.show()
	$CanvasLayer/Panel/AnimationPlayer2.play("show")
	reset_focus()
	
func restart_game():
	is_game_over = false
	resume.visible = true
	restart.visible = false
	gameover.visible = false
	hight_score.visible = false
	resume_game()
	
func reset_focus():
	$CanvasLayer/Panel/PauseMenu/Resume.grab_focus()

func pause_game():
	Engine.time_scale = 0
	get_tree().paused = true
	pass

func resume_game():
	Engine.time_scale = 1
	get_tree().paused = false
	settings.hide()
	ui_layer.hide()

func _on_resume_pressed():
	resume_game()

func _on_option_pressed():
	settings.show()
	settings.reset_focus()

func _on_main_menu_pressed():
	Engine.time_scale = 1
	get_tree().paused = false
	Utilities.switch_scene("MainMenu", self)


func _on_restart_pressed() -> void:
	#map = preload("res://Scenes/Map/Map.tscn").instantiate()
	map.queue_free()
	map = preload("res://Scenes/Map/Map.tscn").instantiate()
	map.game = self
	map.entropy = $Entropy
	add_child(map)
	restart_game()
