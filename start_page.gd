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
	#var username = %username.text
	#var password = %heslo.text
	#if(!username or !password):
	#	alert_dialog.dialog_text = "musíš zadat svoje údaje kamo"
	#	alert_dialog.popup_centered()
	#	return
	#Global.password = password
	#Global.username = username
	
	#var http_node = HTTPRequest.new()
	#add_child(http_node)
	# Connect the signal to a local function
	#http_node.request_completed.connect(_on_request_completed)
	
	# Perform the request
	#var r = "https://quotepy.pythonanywhere.com/verify?user=" + username + "&pass=" + password
	#var error = http_node.request(r)
	
	get_tree().change_scene_to_file("res://game.tscn")
	



func _on_request_completed(result, response_code, headers, body):
	print("Response received: ", response_code)
		
	if response_code == 400:
		alert_dialog.dialog_text = str(response_code)
		alert_dialog.popup_centered()
		#UNCOMMENT IN PROD!!
		return
	get_tree().change_scene_to_file("res://game.tscn")
