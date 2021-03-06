extends KinematicBody2D

signal off_screen(destroyed_obj)

export var velocity = Vector2(-200, 0)
var vel_multiplier = 0
var halfwidth 

var viewport_x = -500 # until I can figure out how to reliably find this value

func _ready():
	halfwidth = $CollisionShape2D.shape.extents.x
	#viewport_x = get_parent().viewport_x
	
func _process(delta):
	if global_position.x <= viewport_x - halfwidth:
		emit_signal("off_screen", self)
	position += velocity * Vector2(1,0) * vel_multiplier * delta
	#velocity = move_and_slide(velocity * vel_multiplier)

