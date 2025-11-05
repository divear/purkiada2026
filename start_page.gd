extends Control

@export var start_button: Button
@export var settings_button: Button

func _ready() -> void:
	# Automatically get buttons if not assigned
	if start_button == null:
		start_button = get_node("MainMenu/CenterContainer/MarginContainer/VBoxContainer/NewGameButton") as Button
	if settings_button == null:
		settings_button = get_node("MainMenu/CenterContainer/MarginContainer/VBoxContainer/SettingsButton") as Button

	# Connect signals
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

	print("Start Page Loaded")

func _on_start_pressed() -> void:
	var game_scene := load("res://game.tscn").instantiate() as Node
	add_child(game_scene)
	print("Start Page")

func _on_settings_pressed() -> void:
	print("nastaveni jsem jeste neudelal")
