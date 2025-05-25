extends RigidBody2D

signal spear_picked_up

@export var stop_below_velocity = 1
@export var initial_velocity_loss = 100  # Slower initial deceleration
@export var max_velocity_loss = 300      # Maximum deceleration
@export var deceleration_curve = 1.0     # How quickly we reach max deceleration
@export var spear_speed = 500.0

@onready var area: Area2D = $Area2D

func _ready():
	print_debug("Spear ready", self)

func spawn(direction: Vector2) -> void:
	direction = direction.normalized()
	rotation = direction.angle()
	
	# Set the spear's velocity
	linear_velocity = direction * spear_speed

func retire_spear() -> void:
	print_debug("Retiring spear", self)
	linear_velocity = Vector2.ZERO
	freeze = true
	area.body_entered.connect(pickup)
	print_debug("Body entered signal connected: ", area.body_entered.is_connected(pickup))

func _physics_process(delta):
	# If the spear is moving too slowly, stop it
	if !freeze:
		var current_velocity = linear_velocity
		var velocity_direction = current_velocity.normalized()
		var current_speed = current_velocity.length()
		
		# Calculate deceleration based on current speed
		# As speed decreases, deceleration increases exponentially
		var speed_ratio = current_speed / spear_speed
		var current_deceleration = lerp(initial_velocity_loss, max_velocity_loss, pow(1 - speed_ratio, deceleration_curve))
		
		# Apply deceleration
		var new_speed = max(0, current_speed - current_deceleration * delta)
		linear_velocity = velocity_direction * new_speed
		
		# Retire spear if it's moving too slowly
		if new_speed < stop_below_velocity:
			retire_spear()

func pickup(_body):
	print_debug("Picking up spear")  # Debug print
	emit_signal("spear_picked_up")
	queue_free()
