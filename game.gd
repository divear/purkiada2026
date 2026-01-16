extends Node2D

# Robot node
var robot: CharacterBody2D


# Command dictionary: command -> function
var commands := {}
var level = 1
var ueberlevel = 1

# Current text lines
var current_text: PackedStringArray = []
var tilemap_position
var player_init_pos

# Exported buttons
@export var run_button: Button
@export var reset_button: Button

func _ready() -> void:
	print("Game Scene Loaded")
	player_init_pos = $robot.position
	var first_level = get_node_or_null("Stones1") 
	if first_level:
		tilemap_position = first_level.position
	else:
		# Fallback: set a default if Stones1 isn't found
		tilemap_position = Vector2.ZERO

	for i in range(20):
		var tilemap = get_node_or_null("Stones" + str(i+2))
		if tilemap:
			tilemap.visible = false
			tilemap.position = Vector2(9999, 9999)
			
			# This is the correct property for TileMapLayer in Godot 4.3+
			tilemap.enabled = false


	#tilemap.hide()
	# ------------------------------
	# RunButton setup

	if run_button == null:
		run_button = get_node_or_null("IDE/RunButton")
	if reset_button == null:
		reset_button = get_node_or_null("IDE/ResetButton")
		
	if run_button:
		run_button.pressed.connect(_on_run_pressed)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)

	# ------------------------------
	# TextEdit setup
	# ------------------------------
	var text_edit := get_node_or_null("IDE/TextEdit") as TextEdit
	if text_edit:
		text_edit.text_changed.connect(_on_text_changed)
		current_text = text_edit.text.split("\n", false)

	# ------------------------------
	# Robot setup
	# ------------------------------
	robot = get_node_or_null("robot") as CharacterBody2D
	if robot == null:
		push_error("Robot node not found!")

	# ------------------------------
	# Initialize commands
	# ------------------------------
	commands = {
		"left": func(step): await _move_robot(Vector2.LEFT, step),
		"right": func(step): await _move_robot(Vector2.RIGHT, step),
		"up": func(step): await _move_robot(Vector2.UP, step),
		"down": func(step): await _move_robot(Vector2.DOWN, step),
		"sleep": func(seconds): await _sleep(seconds)
	}

# ------------------------------
# Text changed handler
# ------------------------------
func _on_text_changed() -> void:
	var text_edit := get_node_or_null("IDE/TextEdit") as TextEdit
	if text_edit:
		current_text = text_edit.text.split("\n", false)

# ------------------------------
# Reset button handler
# ------------------------------
func _on_reset_pressed() -> void:
	get_tree().reload_current_scene()

# ------------------------------
# Run button handler
# ------------------------------
func _on_run_pressed() -> void:
	$robot.position=player_init_pos
	
	await _execute_commands_sequentially()

# ------------------------------
# Execute all commands sequentially
# ------------------------------
func _execute_commands_sequentially() -> void:
	for line in current_text:
		var trimmed := line.strip_edges()
		if trimmed == "":
			continue

		var open := trimmed.find("(")
		var close := trimmed.find(")")

		if open == -1 or close == -1:
			continue

		var command := trimmed.substr(0, open).strip_edges().to_lower()
		var arg_str := trimmed.substr(open + 1, close - open - 1).strip_edges()

		var arg_value := float(arg_str) if arg_str.is_valid_float() else 0.0
		if not arg_str.is_valid_float():
			arg_value = 1.0 if command == "sleep" else 50.0  # default step size
		if arg_value > 10:
			arg_value = 10
		if command in commands:
			await commands[command].call(arg_value)
		else:
			print("Unknown command: %s" % command)

# ------------------------------
# Move the robot smoothly
# ------------------------------
func _move_robot(direction: Vector2, step_size: float) -> void:
	if robot == null:
		return

	var steps := 20
	var move_per_step := step_size * 90.0 / steps
	var delay_per_step := 0.02  # ~50 FPS

	for i in range(steps):
		robot.position += direction * move_per_step
		await get_tree().create_timer(delay_per_step).timeout

	print("Robot moved %s by %s" % [direction, step_size])

# ------------------------------
# Sleep helper
# ------------------------------
func _sleep(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	
	
func _on_flag_body_entered(body: Node2D) -> void:
	if body == robot:
		# 1. Identify the CURRENT level stones and the NEXT level stones
		var current_stones_name = "Stones" + str(level)
		var next_stones_name = "Stones" + str(level + 1)
		
		var current_node = get_node_or_null(current_stones_name)
		var next_node = get_node_or_null(next_stones_name)

		# 2. Show the NEXT level FIRST
		if next_node:
			next_node.enabled = true
			next_node.visible = true # Extra safety
			if tilemap_position != null:
				next_node.position = tilemap_position
			print("Showing: ", next_stones_name)
		else:
			ueberlevel += 1
			print("No more stones found for this section.")

		# 3. NOW delete the old stones
		if current_node:
			current_node.queue_free()

		# 4. Update variables for the next time
		level += 1
		player_init_pos = $robot.position
		$LevelName.text = "LEVEL " + str(ueberlevel) + "." + str(level)
	
	
	# Copy position of Flag to Flag2 safely
	#if first_stones:
		#var flag2 = first_stones.get_node_or_null("Flag2")
		#var flag = game_scene.get_node_or_null("level_flag")
		#print(flag2)
		#print(flag)
		#
		#if flag2 and flag:
			#flag2.position = flag.position
		#else:
			#print("Could not find Flag2 or Flag node!")
		#
		## Now free the old scene
		#first_stones.queue_free()
	
	# Set new scene position


func _on_stones_tree_entered() -> void:
	pass

func _on_skull_body_entered(body: Node) -> void:
		print(body)
		if(body==robot):
			get_tree().reload_current_scene()
	

func _on_win_body_entered(body: Node2D) -> void:
	# Create a temporary HTTPRequest node
	print(body)
	if(body==get_node_or_null("Key")):
		get_tree().change_scene_to_file("res://win.tscn") # Tímto změníte scénu
	
func add_point_to_server():
	var http_node = HTTPRequest.new()
	add_child(http_node)
	
	# Connect the signal to a local function
	http_node.request_completed.connect(_on_request_completed)
	
	# Perform the request
	var error = http_node.request("https://api.github.com/repos/godotengine/godot/releases/latest")
	
	if error != OK:
		print("An error occurred")

# Make sure this matches the signal connection above
func _on_request_completed(result, response_code, headers, body):
	print("Response received: ", response_code)
	# Important: Remove the temporary node to clean up memory
	# You'll need a reference to it, or use a persistent node setup instead.
	
func send_score_to_server(points: int):
	# 1. Prepare the data
	var data = {"user_points": points}
	var json_query = JSON.stringify(data)
	
	# 2. Set the Headers (Tells the server we are sending JSON)
	var headers = ["Content-Type: application/json"]
	
	# 3. Create/Access the node
	var http_node = $HTTPRequest # Ensure this node exists!
	
	if not http_node.request_completed.is_connected(_on_request_completed):
		http_node.request_completed.connect(_on_request_completed)

	# 4. Perform the POST request
	# Parameters: (url, headers, method, raw_data)
	var error = http_node.request(
		"https://your-server.com/api/score", 
		headers, 
		HTTPClient.METHOD_POST, 
		json_query
	)

	if error != OK:
		print("An error occurred in the HTTP request.")
