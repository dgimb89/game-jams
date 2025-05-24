extends CharacterBody2D

@export var speed = 300.0
@export var dash_speed_multiplier = 4.0
@export var dash_duration = 0.2
@export var dash_cooldown = 3.0

var can_dash = true
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0

func _physics_process(delta):
	# Handle dash cooldown
	if not can_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			can_dash = true
	
	# Handle dash duration
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	
	# Get input direction from defined input actions
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	
	# Normalize the direction vector to prevent faster diagonal movement
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	# Handle dash input
	if Input.is_action_just_pressed("dash") and can_dash and direction != Vector2.ZERO:
		is_dashing = true
		dash_timer = dash_duration
		can_dash = false
		dash_cooldown_timer = dash_cooldown
	
	# Set velocity based on direction and speed
	var current_speed = speed * (dash_speed_multiplier if is_dashing else 1.0)
	velocity = direction * current_speed
	
	# Move the character
	move_and_slide()
