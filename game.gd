extends Node2D

# Robot node
var robot: CharacterBody2D

# Command dictionary: command -> function
var commands := {}
var level = 1

# Current text lines
var current_text: PackedStringArray = []

# Exported buttons
@export var run_button: Button
@export var reset_button: Button

func _ready() -> void:
	print("Game Scene Loaded")

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


func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	level+=1
	# tree.change_scene_to_file()

	var first_stones := get_node_or_null("Stones1")
	first_stones.queue_free()
	var game_scene := load("res://levels/stones_%d.tscn" % level).instantiate() as Node
	add_child(game_scene)
	game_scene.position = Vector2(46, 10) # Set position in pixels
	# change level
	print("entered")
