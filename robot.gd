extends CharacterBody2D

const SPEED := 10

func _ready() -> void:
	print("Hello from GDScript to Godot :)")

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_right"):
		position += Vector2(SPEED, 0)
	if Input.is_action_pressed("ui_left"):
		position += Vector2(-SPEED, 0)
	if Input.is_action_pressed("ui_down"):
		position += Vector2(0, SPEED)
	if Input.is_action_pressed("ui_up"):
		position += Vector2(0, -SPEED)
