extends Control

@export var start_button: Button
@onready var alert_dialog = $AcceptDialog
@onready var username_input = $username
@onready var password_input = $password


func _ready() -> void:
	# Automatically get buttons if not assigned
	if start_button == null:
		start_button = get_node("MainMenu/CenterContainer/MarginContainer/VBoxContainer/NewGameButton") as Button

	# Connect signals
	start_button.pressed.connect(_on_start_pressed)

	print("Start Page Loaded")

func _on_start_pressed() -> void:
	var username = %username.text
	var password = %heslo.text
	if(!username or !password):
		alert_dialog.dialog_text = "musíš zadat svoje údaje kamo"
		alert_dialog.popup_centered()
		return
		
	get_tree().change_scene_to_file("res://game.tscn")
	
	print("Start Page")

func _on_settings_pressed() -> void:
	print("nastaveni jsem jeste neudelal")
