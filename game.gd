extends Node2D

# Robot node
var robot: CharacterBody2D

# Command dictionary: command -> function
var commands := {}
var level = 1

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

	for i in range(20):
		print("Stones"+str(i+2))
		if(get_node_or_null("Stones"+str(i+2))):
			var tilemap = get_node("Stones"+str(i+2))
			tilemap_position = tilemap.position
			tilemap.set_physics_process(false)  # stop collisions
			tilemap.visible = false  
			tilemap.position = Vector2(999, 0)  # use a Vector2


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
	if(body==robot):
		level += 1
		player_init_pos = $robot.position
		
		print("it was a robot")
		print(level)
		print(body.name)
		get_node("Stones"+str(level-1)).queue_free()
		print("Stones"+str(level-1))
		# Get references BEFORE freeing
		var first_stones = get_node_or_null("Stones"+str(level-1))
		
		var another_tilemap = get_node_or_null("Stones"+str(level))
		if(another_tilemap):
			another_tilemap.show()
			another_tilemap.position = tilemap_position
		
	
	
	
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
