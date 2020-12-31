extends KinematicBody2D

signal off_screen(destroyed_obj)

export var velocity = -200
var vel_multiplier = 0
var halfwidth 

func _ready():
	halfwidth = $CollisionShape2D.shape.extents.x
	
var time = 0
func _process(delta):
	
	if global_position.x <= -1000:
		emit_signal("off_screen", self)
	position += velocity * Vector2(1,0) * vel_multiplier * delta


