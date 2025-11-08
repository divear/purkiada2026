extends CharacterBody2D

const SPEED := 200.0
const PUSH_FORCE := 550.0
const MIN_PUSH_FORCE := 5.0

func _process(delta: float) -> void:
	var direction := Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	# Normalize direction so diagonal movement isn't faster
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	velocity = direction * SPEED
	move_and_slide()

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			var push_force = (PUSH_FORCE*velocity.length()/SPEED) + MIN_PUSH_FORCE
			collision.get_collider().apply_central_impulse(-collision.get_normal() * push_force)
			print("Collided with: ", collision.get_collider().name)
