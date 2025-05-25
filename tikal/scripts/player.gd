extends CharacterBody2D

@export var speed = 250.0
@export var dash_speed_multiplier = 2.5
@export var dash_duration = 0.5
@export var dash_cooldown = 3.0
@export var attack_duration = 0.5
@export var attack_cooldown = 3.0
@export var spear_speed = 500.0

var can_dash = true
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0

var has_spear = true
var is_attacking = false
var attack_timer = 0.0
var attack_cooldown_timer = 0.0

var last_direction = Vector2.RIGHT

@onready var animated_sprite = $AnimatedSprite2D
@onready var dash_cooldown_bar = $DashCooldownBar
@onready var attack_cooldown_bar = $AttackCooldownBar
@onready var spear_scene = preload("res://scenes/objects/spear.tscn")

func _ready():
	# Set up progress bars
	dash_cooldown_bar.max_value = dash_cooldown
	attack_cooldown_bar.max_value = attack_cooldown

func _physics_process(delta):
	# Handle dash cooldown
	if not can_dash:
		dash_cooldown_timer -= delta
		dash_cooldown_bar.value = dash_cooldown - dash_cooldown_timer
		if dash_cooldown_timer <= 0:
			can_dash = true
	
	# Handle dash duration
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	
	# Handle attack cooldown
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta
		attack_cooldown_bar.value = attack_cooldown - attack_cooldown_timer
	
	# Handle attack duration
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
		# Short circuit - if attacking, only update animation and return
		animated_sprite.play("attack")
		return
	
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
		last_direction = direction  # Update last_direction when moving
	
	# Handle attack input
	if Input.is_action_just_pressed("attack") and has_spear and attack_cooldown_timer <= 0:
		is_dashing = false # cancel dash if it's active
		can_dash = false # cannot dash while attacking
		is_attacking = true
		attack_timer = attack_duration
		has_spear = false
		attack_cooldown_bar.set_colors(Color(0.5, 0, 0, 1))
		attack_cooldown_timer = attack_cooldown
		attack_cooldown_bar.value = 0
		animated_sprite.play("attack")
		# Spawn spear in the current movement direction
		spawn_spear(direction)
		return

	# Handle dash input
	if Input.is_action_just_pressed("dash") and can_dash and direction != Vector2.ZERO:
		is_dashing = true
		dash_timer = dash_duration
		can_dash = false
		dash_cooldown_timer = dash_cooldown
		dash_cooldown_bar.value = 0
	
	# Set velocity based on direction and speed
	var current_speed = speed * (dash_speed_multiplier if is_dashing else 1.0)
	velocity = direction * current_speed
	
	# Move the character
	move_and_slide()
	
	# Update animation based on movement state
	if is_dashing:
		animated_sprite.play("dash")
	elif direction != Vector2.ZERO:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

## Spawns a spear that moves in the specified direction
## @param direction: The direction vector for the spear to move in (will be normalized)
func spawn_spear(direction: Vector2 = Vector2.ZERO) -> void:
	if direction == Vector2.ZERO:
		# If no direction is provided, use the last movement direction
		direction = last_direction
	
	var spear = spear_scene.instantiate()
	spear.spear_picked_up.connect(_on_spear_picked_up)
	get_parent().add_child(spear)
	spear.global_position = global_position
	spear.spawn(direction)

func _on_spear_picked_up() -> void:
	has_spear = true
	attack_cooldown_bar.set_colors(Color(0.5, 0.5, 0, 1))
