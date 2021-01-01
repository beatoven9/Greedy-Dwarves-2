extends KinematicBody2D

export var velocity = -200
var vel_multiplier = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	position += velocity * Vector2(1,0) * vel_multiplier * delta

