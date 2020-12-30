extends KinematicBody2D

signal off_screen

var velocity = Vector2(0,0)

func _ready():
	#self.connect("off_screen", get_owner(), "place_tilemap")
	#print(get_owner())
	pass
	
var time = 0
func _process(delta):
	velocity.x = -300 
	#if global_position.x <= -100:
		#emit_signal("off_screen")
	time+=delta
	if time >= 1:
		print("signal emitted")
		temp_signal()
		time = 0
	position += velocity * delta

func temp_signal():
	emit_signal("off_screen")
