extends CharacterBody2D

@export var speed = 300.0

func _physics_process(delta):
	# Get input direction from both WASD and arrow keys
	var direction = Vector2.ZERO
	
	# WASD controls
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("move_down"):
		direction.y += 1
	
	# Normalize the direction vector to prevent faster diagonal movement
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	# Set velocity based on direction and speed
	velocity = direction * speed
	
	# Move the character
	move_and_slide()
