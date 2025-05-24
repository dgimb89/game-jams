extends Node2D

signal spawn_requested(direction: Vector2)

@onready var rigid_body = $RigidBody2D
@export var stop_below_velocity = 50
@export var initial_velocity_loss = 400  # Slower initial deceleration
@export var max_velocity_loss = 1000      # Maximum deceleration
@export var deceleration_curve = 1.0     # How quickly we reach max deceleration
@export var spear_speed = 800.0

func _ready():
	# Unfreeze the rigid body when the spear is spawned
	rigid_body.freeze = false

func spawn(direction: Vector2) -> void:
	direction = direction.normalized()
	rotation = direction.angle()
	
	# Set the spear's velocity
	if rigid_body:
		rigid_body.linear_velocity = direction * spear_speed

func _physics_process(delta):
	# If the spear is moving too slowly, stop it
	if !rigid_body.freeze:
		var current_velocity = rigid_body.linear_velocity
		var velocity_direction = current_velocity.normalized()
		var current_speed = current_velocity.length()
		
		# Calculate deceleration based on current speed
		# As speed decreases, deceleration increases exponentially
		var speed_ratio = current_speed / spear_speed
		var current_deceleration = lerp(initial_velocity_loss, max_velocity_loss, pow(1 - speed_ratio, deceleration_curve))
		
		# Apply deceleration
		var new_speed = max(0, current_speed - current_deceleration * delta)
		rigid_body.linear_velocity = velocity_direction * new_speed
		
		# Retire spear if it's moving too slowly
		if new_speed < stop_below_velocity:
			rigid_body.linear_velocity = Vector2.ZERO
			rigid_body.freeze = true
			print_debug("freeze ", rigid_body)
