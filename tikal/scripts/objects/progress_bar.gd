extends ProgressBar

@export var empty_color: Color = Color(1, 0, 0, 1)  # Red
@export var custom_fill_color: Color = Color(0, 1, 0, 1)  # Green

func _ready():
	# Create a unique stylebox for this instance
	var fill_style = get_theme_stylebox("fill").duplicate()
	add_theme_stylebox_override("fill", fill_style)
	
	# Connect to the value changed signal
	value_changed.connect(_on_value_changed)
	# Set initial color
	_update_color()

func _on_value_changed(new_value):
	_update_color()

func _update_color():
	# Calculate interpolated color based on value
	var t = value / max_value
	var interpolated_color = empty_color.lerp(custom_fill_color, t)
	
	# Get the fill style and update its color
	var fill_style = get_theme_stylebox("fill")
	if fill_style:
		fill_style.bg_color = interpolated_color

func set_fill_color(color: Color):
	custom_fill_color = color
	_update_color() 
